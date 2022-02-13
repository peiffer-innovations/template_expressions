import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  var context = {
    'a': 'a',
    'b': 'B',
    'c': 'c',
  };

  test('hash syntax', () {
    var syntax = HashExpressionSyntax();
    var template = Template(
      syntax: [HashExpressionSyntax()],
      value: 'Hello World!',
    );

    expect(template.process(context: context), 'Hello World!');

    template = Template(
      syntax: [syntax],
      value: 'Hello ##a##!',
    );
    expect(template.process(context: context), 'Hello a!');

    template = Template(
      syntax: [syntax],
      value: 'Hello ##a + b##!',
    );
    expect(template.process(context: context), 'Hello aB!');

    template = Template(
      syntax: [syntax],
      value: 'Hello ##(a + b).toUpperCase()##!',
    );
    expect(template.process(context: context), 'Hello AB!');

    template = Template(
      syntax: [syntax],
      value: 'Hello ##(a + b).toLowerCase()##!',
    );
    expect(template.process(context: context), 'Hello ab!');

    template = Template(
      syntax: [syntax],
      value: '##a.toUpperCase()## ##b.toLowerCase()##',
    );
    expect(template.process(context: context), 'A b');

    template = Template(
      syntax: [syntax],
      value: '##a.toUpperCase()## \\##b##',
    );
    expect(template.process(context: context), 'A ##b##');

    template = Template(
      syntax: [syntax],
      value: '##a + " " + "\\##b\\##"##',
    );
    expect(template.process(context: context), 'a ##b##');
  });

  test('mixed syntax', () {
    var syntax = [
      HashExpressionSyntax(),
      MustacheExpressionSyntax(),
      StandardExpressionSyntax(),
    ];

    var myContext = {
      'hash': 'HASH',
      'mustache': 'MUSTACHE',
      'standard': 'STANDARD',
    };
    var template = Template(
      syntax: syntax,
      value: 'Hello ##hash## {{mustache}} \${standard}!',
    );

    expect(
      template.process(context: myContext),
      'Hello HASH MUSTACHE STANDARD!',
    );
  });

  test('mustache syntax', () {
    var syntax = MustacheExpressionSyntax();
    var template = Template(
      syntax: [syntax],
      value: 'Hello World!',
    );

    expect(template.process(context: context), 'Hello World!');

    template = Template(
      syntax: [syntax],
      value: 'Hello {{a}}!',
    );
    expect(template.process(context: context), 'Hello a!');

    template = Template(
      syntax: [syntax],
      value: 'Hello {{a + b}}!',
    );
    expect(template.process(context: context), 'Hello aB!');

    template = Template(
      syntax: [syntax],
      value: 'Hello {{(a + b).toUpperCase()}}!',
    );
    expect(template.process(context: context), 'Hello AB!');

    template = Template(
      syntax: [syntax],
      value: 'Hello {{(a + b).toLowerCase()}}!',
    );
    expect(template.process(context: context), 'Hello ab!');

    template = Template(
      syntax: [syntax],
      value: '{{a.toUpperCase()}} {{b.toLowerCase()}}',
    );
    expect(template.process(context: context), 'A b');

    template = Template(
      syntax: [syntax],
      value: '{{a.toUpperCase()}} \\{{b}}',
    );
    expect(template.process(context: context), 'A {{b}}');

    template = Template(
      syntax: [syntax],
      value: '{{a + " " + "{{b\\}}"}}',
    );
    expect(template.process(context: context), 'a {{b}}');
  });

  test('standard syntax', () {
    var syntax = StandardExpressionSyntax();
    var template = Template(
      syntax: [syntax],
      value: 'Hello World!',
    );

    expect(template.process(context: context), 'Hello World!');

    template = Template(
      syntax: [syntax],
      value: r'Hello ${a}!',
    );
    expect(template.process(context: context), 'Hello a!');

    template = Template(
      syntax: [syntax],
      value: r'Hello ${a + b}!',
    );
    expect(template.process(context: context), 'Hello aB!');

    template = Template(
      syntax: [syntax],
      value: r'Hello ${(a + b).toUpperCase()}!',
    );
    expect(template.process(context: context), 'Hello AB!');

    template = Template(
      syntax: [syntax],
      value: r'Hello ${(a + b).toLowerCase()}!',
    );
    expect(template.process(context: context), 'Hello ab!');

    template = Template(
      syntax: [syntax],
      value: r'${a.toUpperCase()} ${b.toLowerCase()}',
    );
    expect(template.process(context: context), 'A b');

    template = Template(
      syntax: [syntax],
      value: r'${a.toUpperCase()} \${b}',
    );
    expect(template.process(context: context), r'A ${b}');

    template = Template(
      syntax: [syntax],
      value: r'${a + " " + "${b\}"}',
    );
    expect(template.process(context: context), r'a ${b}');
  });
}
