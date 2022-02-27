import 'package:template_expressions/template_expressions.dart';

/// Syntax that begins with a dollar sign followed by an opening curley brace,
/// `${` and ends with a single closing curley brace, `}`.
class StandardExpressionSyntax extends ExpressionSyntax {
  const StandardExpressionSyntax()
      : super(
          endToken: '}',
          startToken: r'${',
        );
}
