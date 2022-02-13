import 'package:template_expressions/template_expressions.dart';

class MustacheExpressionSyntax extends ExpressionSyntax {
  const MustacheExpressionSyntax()
      : super(
          endToken: '}}',
          startToken: '{{',
        );
}
