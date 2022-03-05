import 'dart:convert';

import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  group('Codex', () {
    test('base64', () {
      var template = Template(
        value: r'${utf8.decode(base64.decode(input))}',
      );

      expect(
        template.process(context: {'input': 'SGVsbG8gV29ybGQh'}),
        'Hello World!',
      );

      template = Template(
        value: r'${base64.encode(input)}',
      );
      expect(
        template.process(context: {'input': utf8.encode('Hello World!')}),
        'SGVsbG8gV29ybGQh',
      );
    });

    test('hex', () {
      var template = Template(
        value: r'${utf8.decode(hex.decode(hex.encode(utf8.encode(input))))}',
      );

      expect(
        template.process(context: {'input': 'Hello World!'}),
        'Hello World!',
      );
    });

    test('json', () {
      var input = '{"foo":"bar"}';

      var template = Template(
        value: r'${json.encode(json.decode(input))}',
      );

      expect(template.process(context: {'input': input}), input);
    });

    test('utf8', () {
      var template = Template(
        value: r'${utf8.decode(utf8.encode(input))}',
      );

      expect(
        template.process(context: {
          'input': 'Hello World!',
        }),
        'Hello World!',
      );
    });
  });

  group('DateTime', () {
    var start = DateTime(2022, 2, 7);
    test('add', () {
      var context = {
        'start': start,
      };
      var template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{start.add(minutes(5).add(seconds(30)))}}',
      );

      expect(
        template.process(context: context),
        DateTime.fromMillisecondsSinceEpoch(
          start.millisecondsSinceEpoch +
              Duration(
                minutes: 5,
                seconds: 30,
              ).inMilliseconds,
        ).toString(),
      );
    });

    test('subtract', () {
      var context = {
        'start': start,
      };
      var template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{start.subtract(minutes(5).subtract(seconds(30)))}}',
      );

      expect(
        template.process(context: context),
        DateTime.fromMillisecondsSinceEpoch(
          start.millisecondsSinceEpoch -
              Duration(
                minutes: 4,
                seconds: 30,
              ).inMilliseconds,
        ).toString(),
      );
    });
  });
}
