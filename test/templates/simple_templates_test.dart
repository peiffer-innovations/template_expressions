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
      value: '##a.toUpperCase()## \\##b\\##',
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

  test('pipe syntax', () {
    var syntax = PipeExpressionSyntax();
    var template = Template(
      syntax: [PipeExpressionSyntax()],
      value: 'Hello World!',
    );

    expect(template.process(context: context), 'Hello World!');

    template = Template(
      syntax: [syntax],
      value: 'Hello |a|!',
    );
    expect(template.process(context: context), 'Hello a!');

    template = Template(
      syntax: [syntax],
      value: 'Hello |a + b|!',
    );
    expect(template.process(context: context), 'Hello aB!');

    template = Template(
      syntax: [syntax],
      value: 'Hello |(a + b).toUpperCase()|!',
    );
    expect(template.process(context: context), 'Hello AB!');

    template = Template(
      syntax: [syntax],
      value: 'Hello |(a + b).toLowerCase()|!',
    );
    expect(template.process(context: context), 'Hello ab!');

    template = Template(
      syntax: [syntax],
      value: '|a.toUpperCase()| |b.toLowerCase()|',
    );
    expect(template.process(context: context), 'A b');

    template = Template(
      syntax: [syntax],
      value: '|a.toUpperCase()| \\|b|',
    );
    expect(template.process(context: context), 'A |b|');

    template = Template(
      syntax: [syntax],
      value: '|a.toUpperCase()| \\|b\\|',
    );
    expect(template.process(context: context), 'A |b|');

    template = Template(
      syntax: [syntax],
      value: '|a + " " + "\\|b\\|"|',
    );
    expect(template.process(context: context), 'a |b|');
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

  test('map and array', () {
    var template = Template(
      value: r"${concat(['Hello ', name, '!'])}",
    );
    expect(
      template.process(
        context: {
          'concat': (List<dynamic> args) => args.join(''),
          'name': 'Steve',
        },
      ),
      'Hello Steve!',
    );

    template = Template(
      value: r"${concat({'intro': 'Hello ', 'name': name, 'suffix': '!'\})}",
    );
    expect(
      template.process(
        context: {
          'concat': (Map<dynamic, dynamic> args) =>
              args['intro'] + args['name'] + args['suffix'],
          'name': 'Steve',
        },
      ),
      'Hello Steve!',
    );

    template = Template(
      value: r"${concat(['Hello ', '!'], {'name': name\})}",
    );
    expect(
      template.process(
        context: {
          'concat': (List<dynamic> list, Map<dynamic, dynamic> map) =>
              list[0] + map['name'] + list[1],
          'name': 'Steve',
        },
      ),
      'Hello Steve!',
    );

    template = Template(
      value: r'${addAll([add(a, b), x + y])}',
    );
    expect(
      template.process(
        context: {
          'add': (a, b) => a + b,
          'addAll': (List<dynamic> args) => args[0] + args[1],
          'a': 1,
          'b': 2,
          'x': 10,
          'y': 20,
        },
      ),
      (1 + 2 + 10 + 20).toString(),
    );

    template = Template(
      value: r'${addAll([addAll([a, b]), x + y])}',
    );
    expect(
      template.process(
        context: {
          'addAll': (List<dynamic> args) => args[0] + args[1],
          'a': 1,
          'b': 2,
          'x': 10,
          'y': 20,
        },
      ),
      (1 + 2 + 10 + 20).toString(),
    );

    template = Template(
      value: r"${addAll([add({'a': a, 'b': b\}), x + y])}",
    );
    expect(
      template.process(
        context: {
          'add': (Map<dynamic, dynamic> args) => args['a'] + args['b'],
          'addAll': (List<dynamic> args) => args[0] + args[1],
          'a': 1,
          'b': 2,
          'x': 10,
          'y': 20,
        },
      ),
      (1 + 2 + 10 + 20).toString(),
    );
  });

  group('mixed literals', () {
    test('map in array', () {
      var context = <String, Object>{
        'eval': (value) => value[0] + value[1]['name'] + value[2],
      };

      var template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{eval(["Hello ", {"name": "Mike"}, "!"])}}',
      );
      expect(
        template.process(context: context),
        'Hello Mike!',
      );
    });

    test('array in map', () {
      var context = <String, Object>{
        'eval': (value) => value['prefix'] + value['name'][0] + value['suffix'],
      };

      var template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{eval({"prefix": "Hello ", "name": ["Mike"], "suffix":"!"})}}',
      );
      expect(
        template.process(context: context),
        'Hello Mike!',
      );
    });
  });
}
