# =============================================================================
# ALPR Logistic Regression - Real Data Version
# Predicts: correct_read (1 = correct plate, 0 = incorrect)
# Predictors: confidence score, distance (5/10/25/50 m), plate_type (s/t/d)
# =============================================================================

library(tidyverse)
library(readxl)      # if using Excel
library(broom)
library(pROC)
library(ggplot2)
library(scales)

data <- read_csv("alpr.data.csv")

# data <- read_excel("alpr.data.xlsx", sheet = "readings")

# DATA PREPARATION
# Ensure columns have the expected names and types
# Adjust column names below if yours are different (e.g., "dist_m", "plateType", etc.)

data <- data %>%
  mutate(
    # Make sure these column names match your file exactly!
    distance = as.factor(distance),                    # should be 5, 10, 25, 50
    plate_type = as.factor(plate_type),                # standard, taxi, diplomat
    confidence = as.numeric(confidence),               # 0–100 or 0–1 scale
    correct_read = as.integer(correct_read)            # 1 = correct, 0 = incorrect
  ) %>%
  # filter out missing or invalid rows
  filter(!is.na(confidence), !is.na(correct_read), !is.na(distance), !is.na(plate_type)) %>%
  # Ensure confidence is between 0 and 100 (adjust for data uses 0–1)
  mutate(confidence = ifelse(confidence > 1 & confidence <= 100, confidence, confidence * 100))

# Quick check
glimpse(data)
table(data$distance, data$plate_type)
summary(data$confidence)

# LOGISTIC REGRESSION MODEL
model <- glm(correct_read ~ confidence * distance + plate_type,
             data = data,
             family = binomial(link = "logit"))

# Model summary
summary(model)

# Odds ratios with confidence intervals
tidy_model <- tidy(model, exponentiate = TRUE, conf.int = TRUE) %>%
  mutate(significant = ifelse(conf.int.low > 1 | conf.int.high < 1, "Yes", "No"))
print(tidy_model, digits = 3)

# MODEL PERFORMANCE
data$pred_prob <- predict(model, type = "response")
data$pred_class <- ifelse(data$pred_prob >= 0.5, 1, 0)

# Accuracy
accuracy <- mean(data$correct_read == data$pred_class, na.rm = TRUE)
cat("\nAccuracy:", percent(accuracy, accuracy = 0.1), "\n")

# AUC
roc_obj <- roc(data$correct_read, data$pred_prob, quiet = TRUE)
auc_value <- auc(roc_obj)
cat("AUC:", round(auc_value, 4), "\n")

# ROC plot
ggroc(roc_obj) +
  geom_abline(intercept = 1, slope = 1, linetype = "dashed", color = "black") +
  labs(title = paste("ROC Curve (AUC =", round(auc_value, 3), ")")) +
  theme_minimal()

# Predicted prob curves
newdata <- expand_grid(
  confidence = seq(from = min(data$confidence), to = max(data$confidence), length.out = 200),
  distance = factor(c(5, 10, 25, 50)),
  plate_type = factor(c("standard", "taxi", "diplomat"))
)

newdata$prob_correct <- predict(model, newdata = newdata, type = "response")

# Plot by plate type
ggplot(newdata, aes(x = confidence, y = prob_correct, color = distance)) +
  geom_line(size = 1.1) +
  facet_wrap(~ plate_type, ncol = 3) +
  labs(
    title = "Predicted Probability of Correct ALPR Read",
    subtitle = "By Confidence Score, Distance, and Plate Type",
    x = "Confidence Score",
    y = "Probability of Correct Read",
    color = "Distance (m)"
  ) +
  scale_y_continuous(labels = percent_format()) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

# OPTIONAL: Find optimal confidence threshold per distance
thresholds <- newdata %>%
  group_by(distance, plate_type) %>%
  arrange(desc(prob_correct)) %>%
  slice(1) %>%
  ungroup() %>%
  select(distance, plate_type, confidence_threshold = confidence, prob_correct)

print(thresholds)

thresholds %>%
  filter(prob_correct >= 0.85) %>%
  arrange(distance)

# RESULTS
write_csv(tidy_model, "model_coefficients.csv")
write_csv(data %>% select(distance, plate_type, confidence, correct_read, pred_prob), 
          "predictions_with_probabilities.csv")
saveRDS(model, "alpr_logistic_model.rds")

cat("\nDone! Model saved as 'alpr_logistic_model.rds'\n")
cat("Results exported. Check plots and threshold recommendations.\n")
