import 'package:logging/logging.dart';
import 'package:template_expressions/template_expressions.dart';

class Template {
  Template({
    required String value,
    List<ExpressionSyntax>? syntax,
  })  : _syntax = syntax?.isNotEmpty == true
            ? syntax!
            : const [StandardExpressionSyntax()],
        _value = value;

  static final Logger _logger = Logger('Template');

  final List<ExpressionSyntax> _syntax;
  final String _value;

  String process({
    Map<dynamic, dynamic> context = const {},
    List<MemberAccessor<dynamic>> memberAccessors = const [],
  }) {
    final ctx = <String, Object>{};
    for (var entry in context.entries) {
      if (entry.key != null && entry.value != null) {
        ctx[entry.key.toString()] = entry.value;
      }
    }

    final prepared = _prepare();
    var data = prepared.data;

    final evaluator = ExpressionEvaluator(
      memberAccessors: memberAccessors,
    );
    for (var entry in prepared.entries) {
      try {
        final evaled = evaluator.eval(Expression.parse(entry.content), ctx);
        data = entry.replace(
          data,
          evaled == null ? '' : evaled.toString().trim(),
        );
      } catch (e, stack) {
        _logger.severe('Unable to parse input: [${entry.content}]', e, stack);
        rethrow;
      }
    }

    return data;
  }

  Future<String> processAsync({
    Map<dynamic, dynamic> context = const {},
    List<MemberAccessor<dynamic>> memberAccessors = const [],
  }) async {
    final ctx = <String, Object>{};
    for (var entry in context.entries) {
      if (entry.key != null && entry.value != null) {
        ctx[entry.key.toString()] = entry.value;
      }
    }

    final prepared = _prepare();
    var data = prepared.data;

    final evaluator = ExpressionEvaluator.async(
      memberAccessors: memberAccessors,
    );
    for (var entry in prepared.entries) {
      try {
        final evaled = await evaluator
            .eval(
              Expression.parse(entry.content),
              ctx,
            )
            .first;
        data = entry.replace(
          data,
          evaled == null ? '' : evaled.toString().trim(),
        );
      } catch (e, stack) {
        _logger.severe('Unable to parse input: [${entry.content}]', e, stack);
        rethrow;
      }
    }

    return data;
  }

  _ExpressionResult _prepare() {
    final buffer = StringBuffer();
    final length = _value.length;
    final entries = <ExpressionEntry>[];

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
        final syntax = entry.syntax;

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

    entries.sort();

    return _ExpressionResult(
      data: buffer.toString(),
      entries: entries,
    );
  }
}

class _ExpressionResult {
  _ExpressionResult({
    required this.data,
    required this.entries,
  });

  final String data;
  final List<ExpressionEntry> entries;
}
