/// Class that defines the beginning, end, and escape character(s) for an
/// expression.
class ExpressionSyntax {
  const ExpressionSyntax({
    required this.endToken,
    this.escapeChar = '\\',
    required this.startToken,
  });

  /// The character sequence that defines the end of the expression.
  final String endToken;

  /// The character sequence that defines escape character to ignore start or
  /// end tokens.
  final String escapeChar;

  /// The character sequence that defines the start of the expression.
  final String startToken;
}
