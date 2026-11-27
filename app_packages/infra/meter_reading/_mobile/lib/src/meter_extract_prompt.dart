/// メーター抽出用の固定プロンプト（OS LLM / メーター VL 共通）。
///
/// Example:
/// ```dart
/// meterExtractPrompt;
/// ```
const meterExtractPrompt =
    'Read a stationary bike meter LCD.\n'
    'Extract only: distance (km), workout time, and calories (kcal).\n'
    'Ignore Speed and Odo/Pulse.\n'
    'Distance: the number under Distance / DISTANCE KM (unit km).\n'
    'Calories: the number under Calorie / CALORIES (unit kcal).\n'
    'Time (important):\n'
    '- Prefer the number directly above the printed "Time" label.\n'
    '- Else use the largest center readout that looks like mm:ss or HH:mm:ss '
    '(digits with one or two colons).\n'
    '- Do not use Speed / Distance / Calories / Odo numbers as time.\n'
    '- First copy the display string as-is into "time".\n'
    '- Then split it:\n'
    '  - mm:ss -> time-hour=0, time-min=mm, time-sec=ss\n'
    '  - HH:mm:ss -> time-hour=HH, time-min=mm, time-sec=ss\n'
    '- Example: "30:34" => time="30:34", time-hour=0, time-min=30, time-sec=34\n'
    'Reply with JSON only. Unreadable fields must be null. '
    'Do not invent values.\n'
    '{\n'
    '  "distance": <number|null>,\n'
    '  "time": <string|null>,\n'
    '  "time-hour": <number|null>,\n'
    '  "time-min": <number|null>,\n'
    '  "time-sec": <number|null>,\n'
    '  "calories": <number|null>\n'
    '}';
