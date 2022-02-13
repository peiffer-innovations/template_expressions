import 'package:template_expressions/template_expressions.dart';

class StandardExpressionSyntax extends ExpressionSyntax {
  const StandardExpressionSyntax()
      : super(
          endToken: '}',
          startToken: r'${',
        );
}
