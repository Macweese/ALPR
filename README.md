# ALPR: Automatic License Plate Reader

[![Actions status](https://github.com/ankandrew/fast-alpr/actions/workflows/test.yaml/badge.svg)](https://github.com/ankandrew/fast-alpr/actions)
[![Actions status](https://github.com/ankandrew/fast-alpr/actions/workflows/release.yaml/badge.svg)](https://github.com/ankandrew/fast-alpr/actions)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Pylint](https://img.shields.io/badge/linting-pylint-yellowgreen)](https://github.com/pylint-dev/pylint)
[![Checked with mypy](http://www.mypy-lang.org/static/mypy_badge.svg)](http://mypy-lang.org/)
[![ONNX Model](https://img.shields.io/badge/model-ONNX-blue?logo=onnx&logoColor=white)](https://onnx.ai/)
[![Hugging Face Spaces](https://img.shields.io/badge/🤗%20Hugging%20Face-Spaces-orange)](https://huggingface.co/spaces/ankandrew/fast-alpr)
[![Documentation Status](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://ankandrew.github.io/fast-alpr/)
[![Python Version](https://img.shields.io/pypi/pyversions/fast-alpr)](https://www.python.org/)
[![GitHub version](https://img.shields.io/github/v/release/ankandrew/fast-alpr)](https://github.com/ankandrew/fast-alpr/releases)
[![License](https://img.shields.io/github/license/ankandrew/fast-alpr)](./LICENSE)

High-performance, customizable Automatic License Plate Recognition (ALPR) system. We offer fast and
efficient ONNX models by default, but you can easily swap in your own models if needed.

Uses EasyOCR default for Optical Character Recognition (OCR), and [open-image-models](https://github.com/ankandrew/open-image-models) for license plate detection. OCR and model integration is modular.

###  Installation

```shell
pip install fast-alpr[onnx-gpu]
```

By default, **no ONNX runtime is installed**. To run inference, you **must** install at least one ONNX backend using an appropriate extra.

| Platform/Use Case  | Install Command                        | Notes                |
|--------------------|----------------------------------------|----------------------|
| CPU (default)      | `pip install fast-alpr[onnx]`          | Cross-platform       |
| NVIDIA GPU (CUDA)  | `pip install fast-alpr[onnx-gpu]`      | Linux/Windows        |
| Intel (OpenVINO)   | `pip install fast-alpr[onnx-openvino]` | Best on Intel CPUs   |
| Windows (DirectML) | `pip install fast-alpr[onnx-directml]` | For DirectML support |
| Qualcomm (QNN)     | `pip install fast-alpr[onnx-qnn]`      | Qualcomm chipsets    |



```python
from fast_alpr import ALPR

# You can also initialize the ALPR with custom plate detection and OCR models.
alpr = ALPR(
    detector_model="yolo-v9-t-384-license-plate-end2end",
    ocr_model="cct-xs-v1-global-model",
)

# The "assets/test_image.png" can be found in repo root dir
alpr_results = alpr.predict("assets/test_image.png")
print(alpr_results)
```


Annotation:

```python
import cv2

from fast_alpr import ALPR

# Initialize the ALPR
alpr = ALPR(
    detector_model="yolo-v9-t-384-license-plate-end2end",
    ocr_model="cct-xs-v1-global-model",
)

# Load the image
image_path = "assets/test_image.png"
frame = cv2.imread(image_path)

# Draw predictions on the image
annotated_frame = alpr.draw_predictions(frame)
```

Annotated frames:

<img width="400" height="250" alt="image" src="https://github.com/user-attachments/assets/496ead6f-29ce-4c99-b0ea-831d94d09988" />
<img width="400" height="250" alt="image" src="https://github.com/user-attachments/assets/52b311b7-be87-48f6-ade1-fc768361bc97" />


Read API docs [here](https://ankandrew.github.io/fast-alpr/)  


Acknowledgements  

[fast-plate-ocr](https://github.com/ankandrew/fast-plate-ocr) for default OCR models.  
[open-image-models](https://github.com/ankandrew/open-image-models) for default plate detection models.

