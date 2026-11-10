/// Rough token estimate for engines that cannot count exactly.
///
/// ASCII is treated as ~4 characters per token; non-ASCII (e.g. Japanese) as
/// about one token per code unit.
int estimateTokens(String text) {
  if (text.isEmpty) return 0;
  var ascii = 0;
  var other = 0;
  for (final unit in text.codeUnits) {
    if (unit < 0x80) {
      ascii++;
    } else {
      other++;
    }
  }
  return (ascii / 4).ceil() + other;
}
