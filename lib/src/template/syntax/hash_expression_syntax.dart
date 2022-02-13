import 'package:template_expressions/template_expressions.dart';

class HashExpressionSyntax extends ExpressionSyntax {
  const HashExpressionSyntax()
      : super(
          endToken: '##',
          startToken: '##',
        );
}
