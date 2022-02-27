import 'package:template_expressions/template_expressions.dart';

/// Syntax that begins and ends with a single pipe, `|`, character.
class PipeExpressionSyntax extends ExpressionSyntax {
  const PipeExpressionSyntax()
      : super(
          endToken: '|',
          startToken: '|',
        );
}
