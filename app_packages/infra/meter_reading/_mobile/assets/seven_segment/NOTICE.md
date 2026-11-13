Seven-segment digit detector models
===================================

## Android (TFLite FLOAT32)
File: digital_meter_electricity_swift_yolo_192_float32.tflite
URL:
  https://files.seeedstudio.com/sscma/model_zoo/detection/electricity_meter/yolov5_tiny_1xb16_300e_coco_float32_sha1_e46a4c7183d073a5807e327d6b6d788853f2acf7.tflite
Bytes: 2868216
SHA-1: e46a4c7183d073a5807e327d6b6d788853f2acf7
SHA-256: 998d754bedba1e0254c9afbb0b62fedc456641b461bb6a9327f5410ad211b63b

## iOS (Core ML)
File: DigitalMeterElectricity192.mlpackage
Source weights (.pth):
  https://files.seeedstudio.com/sscma/model_zoo/detection/electricity_meter/yolov5_tiny_1xb16_300e_coco_sha1_b26cffe14038a7155315c40b49f851679a547dec.pth
Conversion: tool/seven_segment/convert_coreml.py (coremltools) — **macOS required**
Status: mlpackage not generated on Linux (BlobWriter unavailable). Run convert_coreml.md on macOS, then fill bytes/sha256 and Swift I/O names.
Bytes: <fill after conversion>
SHA-256: <fill after conversion>

License: MIT (SSCMA Model Zoo model card)
Source: Seeed Studio SSCMA — Digital Meter Electricity Swift-YOLO 192
