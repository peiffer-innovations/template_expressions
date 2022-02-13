class ExpressionSyntax {
  const ExpressionSyntax({
    required this.endToken,
    this.escapeChar = '\\',
    required this.startToken,
  });

  final String endToken;
  final String escapeChar;
  final String startToken;
}
