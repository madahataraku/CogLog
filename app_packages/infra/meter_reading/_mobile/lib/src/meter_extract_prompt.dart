/// メーター抽出用の固定プロンプト（OS LLM / Gemma 共通）。
///
/// Example:
/// ```dart
/// meterExtractPrompt;
/// ```
const meterExtractPrompt =
    'You extract stationary bike meter panel values from the image.\n'
    'Reply with ONLY these lines (omit unknown):\n'
    'DISTANCE_KM=<number>\n'
    'DURATION=H:MM:SS\n'
    'CALORIES_KCAL=<number>\n'
    'AVERAGE_SPEED_KMH=<number>\n'
    'Use ASCII digits. No other text.';
