import 'package:template_expressions/template_expressions.dart';

/// Represents an entry in a template that may be an expression
class ExpressionEntry implements Comparable<ExpressionEntry> {
  /// Creates the entry with the associated syntax and the start position within
  /// the template for where this entry was created.
  ExpressionEntry({
    required this.syntax,
    required this.startPosition,
  });

  /// The start position in the template for this entry.
  final int startPosition;

  /// The syntax that is being used for this entry.
  final ExpressionSyntax syntax;

  final StringBuffer _value = StringBuffer();

  /// Returns the content of the entry.  The content will exclude the syntax
  /// tokens.
  String get content => _value.toString().substring(
        syntax.startToken.length,
        _value.length - syntax.endToken.length,
      );

  /// Returns the full value of the entry, including any syntax tokens.
  String get value => _value.toString();

  /// Appends a character to the entry.
  void append(String ch) => _value.write(ch);

  /// Compares the entry to another entry by comparing their relative start
  /// position.  This will return negative if it comes before the other entry,
  /// zero if they start at the same place, and positive if this comes after the
  /// other entry in the template.
  @override
  int compareTo(ExpressionEntry entry) => entry.startPosition - startPosition;

  /// Replaces the content of the [target] template with a new value for this
  /// entry.  This knows it's place within the target and will replace the value
  /// in the target with the [newValue] that was passed in.
  String replace(String target, String newValue) {
    var prefix = target.substring(0, startPosition);
    var suffix = target.substring(
      startPosition + _value.length,
      target.length,
    );

    return '${prefix}${newValue}${suffix}';
  }
}
