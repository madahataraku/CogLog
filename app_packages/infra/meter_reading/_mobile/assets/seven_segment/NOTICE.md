Seven-segment digit detector models
===================================

## Android (TFLite FLOAT32)
File: seven_segment_swift_yolo_192_float32.tflite
Training dataset: LibreYOLO/digits-t2eg6 (CC BY 4.0)
  https://huggingface.co/datasets/LibreYOLO/digits-t2eg6
  Upstream: Roboflow 100 digits-t2eg6
Trainer: Seeed-Studio/ModelAssistant (Apache-2.0), Swift-YOLO tiny @ 192
Export: tool/seven_segment/export_tflite_float32.py (NHWC, score÷100)
Bytes: 3878104
SHA-1: 77f0117e1c5bf98dbdce5fcab4704084f80f9925
SHA-256: f259fa516ae50628bab2b3e8561496d89ab9a214657c350d597fcebd567df0fc
I/O: input [1,192,192,3] float32 / output [1,2268,15] float32

## iOS (Core ML)
File: SevenSegment192.mlpackage
Source weights (.pth):
  https://files.seeedstudio.com/sscma/model_zoo/detection/electricity_meter/yolov5_tiny_1xb16_300e_coco_sha1_b26cffe14038a7155315c40b49f851679a547dec.pth
Conversion: tool/seven_segment/convert_coreml.py (coremltools) — **macOS required**
Status: bundled at ios/Resources/SevenSegment192.mlpackage
I/O names: input / output
Output shape: (1, 2268, 15)
Bytes (tree): 1530698
SHA-256 (tree aggregate): fae51fe46c40838a00fc221faf75cc0b3a6cc550b55028baa951bf0bda6e5ee5
Note: Still the previous Seeed electricity-meter zoo model. Replace when Colab
`.pth` → Core ML conversion is provided (deepen_factor_mode=off).

License (Android weights / dataset): CC BY 4.0 (digits-t2eg6) + Apache-2.0 (ModelAssistant)
License (iOS, current): MIT (SSCMA Model Zoo model card) until replaced

The iOS Core ML package is derived from the SSCMA Model Zoo pre-trained model
(Digital Meter Electricity Swift-YOLO 192). Per
https://github.com/Seeed-Studio/sscma-model-zoo/blob/main/LICENSES
and the model card License: MIT:

MIT License

Copyright (c) 2023 Seeed Studio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
