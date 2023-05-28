import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  group('nullable', () {
    final context = {
      'person': {
        'name': {
          'first': 'John',
          'last': 'Doe',
        },
      },
    };

    test('null check', () {
      var template = Template(
        value: r'${foo != null ? "notNull": "null"}',
      );
      // expect(
      //   template.process(context: context),
      //   'null',
      // );
      template = Template(
        value: r'${foo != null}',
      );
      expect(
        template.evaluate(context: context),
        false,
      );
      template = Template(
        value: r'${foo == null}',
      );
      expect(
        template.evaluate(context: context),
        true,
      );
    });

    test('nullable call', () {
      final template = Template(
        value: r'${map.isNotEmpty == true ? "notEmpty": "empty"}',
      );
      expect(
        template.process(context: context),
        'empty',
      );
    });

    test('nullable evaluation', () {
      final template = Template(
        value: r'${map.isNotEmpty ? "notEmpty": "empty"}',
      );
      expect(
        template.process(context: context),
        'empty',
      );
    });

    test('nullable map', () {
      final template = Template(
        value: r'${map["foo"].isNotEmpty}',
      );
      expect(
        template.process(context: context),
        '',
      );
    });

    test('nullable map', () {
      final template = Template(
        value: r'${map["foo"].isNotEmpty == true ? "notEmpty": "empty"}',
      );
      expect(
        template.process(context: context),
        'empty',
      );
    });

    test('json_path: nullable', () {
      final template = Template(
        value:
            r'${json_path(person, "$.name.firstName").isNotEmpty == true ? "notEmpty" : "empty"}',
      );

      expect(
        template.process(context: context),
        'empty',
      );
    });
  });
}
