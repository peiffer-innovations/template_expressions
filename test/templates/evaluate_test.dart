import 'package:logging/logging.dart';
import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('${record.stackTrace}');
    }
  });

  group('evaluate', () {
    test('async', () async {
      final template = Template(value: r'${seconds(2)}');
      final result = await template.evaluateAsync();

      expect(result, const Duration(seconds: 2));
    });

    test('multiple expressions', () {
      final template = Template(value: r'${seconds(2)}${milliseconds(500)}');
      try {
        template.evaluate();
        fail('expected expression');
      } catch (_) {
        // pass
      }
    });

    test('no expression', () {
      final template = Template(value: '2');
      final result = template.evaluate();

      expect(result, '2');
    });

    test('sync', () {
      final template = Template(value: r'${seconds(2)}');
      final result = template.evaluate();

      expect(result, const Duration(seconds: 2));
    });
  });
}
