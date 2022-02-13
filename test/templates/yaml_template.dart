import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  var context = {
    'person': {
      'firstName': 'John',
      'lastName': 'Smith',
    },
  };

  test('yaml template', () {
    var template = Template(value: _kTemplate);

    var result = template.process(context: context);

    expect(result, '''
firstName: John
lastName: Smith
email: john.smith@example.com
''');
  });
}

const _kTemplate = r'''
firstName: ${person['firstName']}
lastName: ${person['lastName']}
email: ${(person['firstName']).toLowerCase()}.${(person['lastName']).toLowerCase()}@example.com
''';
