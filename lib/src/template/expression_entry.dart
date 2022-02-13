import 'package:template_expressions/template_expressions.dart';

class TemplateEntry implements Comparable<TemplateEntry> {
  TemplateEntry({
    required this.syntax,
    required this.startPosition,
  });

  final int startPosition;
  final ExpressionSyntax syntax;

  final StringBuffer _value = StringBuffer();

  String get content => _value.toString().substring(
        syntax.startToken.length,
        _value.length - syntax.endToken.length,
      );
  String get value => _value.toString();

  void append(String ch) => _value.write(ch);

  @override
  int compareTo(TemplateEntry entry) => entry.startPosition - startPosition;

  String replace(String target, String newValue) {
    var prefix = target.substring(0, startPosition);
    var suffix = target.substring(
      startPosition + _value.length,
      target.length,
    );

    return '${prefix}${newValue}${suffix}';
  }
}
