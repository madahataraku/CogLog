/// メーター抽出用の固定プロンプト（OS LLM / メーター VL 共通）。
///
/// Example:
/// ```dart
/// meterExtractPrompt;
/// ```
const meterExtractPrompt =
    'Read the meter panel of a stationary exercise bike.\n'
    'Needed fields are distance, time, and calories.\n'
    'For distance, look for a Distance label or a number shown with the unit km.\n'
    'For time, look for a Time label or digits separated by colons. '
    'It is usually mm:ss or HH:mm:ss. '
    'If there is only one colon, read it as minutes and seconds.\n'
    'For calories, look for a Calorie label or a number shown with the unit Kcal. '
    'Treat the value as kcal.\n'
    'Reply with JSON only, using exactly this shape. '
    'Do not output any text outside JSON.\n'
    'If a field is unreadable, use null for that field. '
    'Do not invent numbers.\n'
    '{\n'
    '  "distance": <number|null>,\n'
    '  "time-hour": <number|null>,\n'
    '  "time-min": <number|null>,\n'
    '  "time-sec": <number|null>,\n'
    '  "calories": <number|null>\n'
    '}';
