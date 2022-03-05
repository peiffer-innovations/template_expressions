import 'package:template_expressions/template_expressions.dart';

class Template {
  Template({
    required String value,
    List<ExpressionSyntax>? syntax,
  })  : _syntax = syntax?.isNotEmpty == true
            ? syntax!
            : const [StandardExpressionSyntax()],
        _value = value;

  static final Map<String, Object> _delegate = {
    ...CodexFunctions.members,
    ...DateTimeFunctions.functions,
    ...DurationFunctions.functions,
    ...JsonPathFunctions.functions,
    'value': (value) => value,
  };

  final List<ExpressionSyntax> _syntax;
  final String _value;

  String process({Map<dynamic, dynamic> context = const {}}) {
    var buffer = StringBuffer();
    var length = _value.length;
    var entries = <ExpressionEntry>[];

    var ctx = <String, Object>{};
    for (var entry in context.entries) {
      if (entry.key != null && entry.value != null) {
        ctx[entry.key.toString()] = entry.value;
      }
    }

    _delegate.forEach((key, value) => ctx.putIfAbsent(key, () => value));

    ExpressionEntry? entry;

    var start = '';
    var end = '';

    for (var i = 0; i < length; i++) {
      var ch = _value.substring(i, i + 1);

      if (entry == null) {
        start += ch;

        var startSyntax = false;
        for (var syntax in _syntax) {
          if (syntax.escapeChar == ch &&
              i < _value.length - 1 &&
              syntax.startToken.startsWith(_value.substring(i + 1, i + 2))) {
            start = '';
            i++;
            ch = _value.substring(i, i + 1);
          } else {
            if (syntax.startToken.startsWith(start)) {
              startSyntax = true;

              if (syntax.startToken == start) {
                entry = ExpressionEntry(
                  syntax: syntax,
                  startPosition: (i + 1) - start.length,
                );
                entry.append(start);
                start = '';
                end = '';
              }
            }
          }
        }
        if (!startSyntax) {
          start = '';
        }
      } else {
        end += ch;
        var syntax = entry.syntax;

        if (syntax.escapeChar == ch &&
            i < _value.length - 1 &&
            syntax.endToken.startsWith(_value.substring(i + 1, i + 2))) {
          end = '';
          i++;
          ch = _value.substring(i, i + 1);
          entry.append(ch);
        } else {
          entry.append(ch);
          if (syntax.endToken.startsWith(end)) {
            if (syntax.endToken == end) {
              entries.add(entry);
              entry = null;
              start = '';
              end = '';
            }
          } else {
            end = '';
          }
        }
      }

      buffer.write(ch);
    }

    var data = buffer.toString();

    entries.sort();
    var evaluator = const ExpressionEvaluator();
    for (var entry in entries) {
      data = entry.replace(
        data,
        evaluator.eval(Expression.parse(entry.content), ctx).toString(),
      );
    }

    return data;
  }
}
