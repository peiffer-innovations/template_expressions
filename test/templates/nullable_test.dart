import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  group('nullable', () {
    var context = {
      'person': {
        'name': {
          'first': 'John',
          'last': 'Doe',
        },
      },
    };

    test('nullable map', () {
      var template = Template(
        value: r'${map["foo"].isNotEmpty}',
      );
      expect(
        template.process(context: context),
        '',
      );
    });

    test('nullable map', () {
      var template = Template(
        value: r'${map["foo"].isNotEmpty == true ? "notEmpty": "empty"}',
      );
      expect(
        template.process(context: context),
        'empty',
      );
    });

    test('json_path: nullable', () {
      var template = Template(
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
