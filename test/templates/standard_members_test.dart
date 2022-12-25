import 'dart:convert';

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

  group('Codex', () {
    test('base64', () {
      const input =
          r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=`~!@#$%^&*()_+[]{},./<>?;:"\|';
      var template = Template(
        value: r'${utf8.decode(base64.decode(input))}',
      );

      expect(
        template.process(context: {
          'input':
              'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjEyMzQ1Njc4OTAtPWB+IUAjJCVeJiooKV8rW117fSwuLzw+Pzs6Ilx8'
        }),
        input,
      );

      template = Template(
        value: r'${base64.encode(input)}',
      );
      expect(
        template.process(context: {'input': utf8.encode(input)}),
        'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjEyMzQ1Njc4OTAtPWB+IUAjJCVeJiooKV8rW117fSwuLzw+Pzs6Ilx8',
      );
    });

    test('base64url', () {
      const input =
          r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=`~!@#$%^&*()_+[]{},./<>?;:"\|';
      var template = Template(
        value: r'${utf8.decode(base64url.decode(input))}',
      );

      expect(
        template.process(
          context: {
            'input':
                'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjEyMzQ1Njc4OTAtPWB-IUAjJCVeJiooKV8rW117fSwuLzw-Pzs6Ilx8'
          },
        ),
        input,
      );

      template = Template(
        value: r'${base64url.encode(input)}',
      );
      expect(
        template.process(context: {'input': utf8.encode(input)}),
        'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjEyMzQ1Njc4OTAtPWB-IUAjJCVeJiooKV8rW117fSwuLzw-Pzs6Ilx8',
      );
    });

    test('hex', () {
      final template = Template(
        value: r'${utf8.decode(hex.decode(hex.encode(utf8.encode(input))))}',
      );

      expect(
        template.process(context: {'input': 'Hello World!'}),
        'Hello World!',
      );
    });

    test('json', () {
      const input = '{"foo":"bar"}';

      final template = Template(
        value: r'${json.encode(json.decode(input))}',
      );

      expect(template.process(context: {'input': input}), input);
    });

    test('utf8', () {
      final template = Template(
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
    final start = DateTime(2022, 2, 7);
    test('add', () {
      final context = {
        'start': start,
      };
      final template = Template(
        syntax: [const MustacheExpressionSyntax()],
        value: '{{start.add(minutes(5).add(seconds(30)))}}',
      );

      expect(
        template.process(context: context),
        DateTime.fromMillisecondsSinceEpoch(
          start.millisecondsSinceEpoch +
              const Duration(
                minutes: 5,
                seconds: 30,
              ).inMilliseconds,
        ).toString(),
      );
    });

    test('subtract', () {
      final context = {
        'start': start,
      };
      final template = Template(
        syntax: [const MustacheExpressionSyntax()],
        value: '{{start.subtract(minutes(5).subtract(seconds(30)))}}',
      );

      expect(
        template.process(context: context),
        DateTime.fromMillisecondsSinceEpoch(
          start.millisecondsSinceEpoch -
              const Duration(
                minutes: 4,
                seconds: 30,
              ).inMilliseconds,
        ).toString(),
      );
    });
  });

  group('List', () {
    test('toJson', () {
      final context = {
        'input': [
          'John',
          'Smith',
        ]
      };

      expect(
        Template(value: r'${input.toJson(2)}').process(context: context),
        const JsonEncoder.withIndent('  ').convert(context['input']),
      );

      expect(
        Template(value: r'${input.toJson()}').process(context: context),
        json.encode(context['input']),
      );
    });
  });

  group('Logger', () {});

  group('Map', () {
    test('toJson', () {
      final context = {
        'input': {
          'name': {
            'first': 'John',
            'last': 'Smith',
          },
        },
      };

      expect(
        Template(value: r'${input.toJson(2)}').process(context: context),
        const JsonEncoder.withIndent('  ').convert(context['input']),
      );

      expect(
        Template(value: r'${input.toJson()}').process(context: context),
        json.encode(context['input']),
      );
    });
  });

  group('MapEntry', () {
    test('key / value', () {
      final context = {
        'input': const MapEntry('KEY', 'VALUE'),
      };

      expect(
        Template(value: r'${input.key}').process(context: context),
        'KEY',
      );

      expect(
        Template(value: r'${input.value}').process(context: context),
        'VALUE',
      );
    });
  });

  group('String', () {
    test('decode', () {
      final template = Template(
        value: r'${input.decode()["last"] + ", " + input.decode()["first"]}',
      );

      expect(
        template.process(context: {
          'input': '{"first": "John", "last": "Smith"}',
        }),
        'Smith, John',
      );
    });

    test('replaceAll', () {
      final template = Template(value: r'${input.replaceAll("\n", "\\n")}');

      expect(
        template.process(
          context: {
            'input': 'a\nb\nc\n',
          },
        ),
        'a\\nb\\nc\\n',
      );
    });

    test('toLowerCase', () {
      final template = Template(
        value: r'${input.toLowerCase()}',
      );

      expect(
        template.process(context: {
          'input': 'Hello World!',
        }),
        'hello world!',
      );
    });

    test('toUpperCase', () {
      final template = Template(
        value: r'${input.toUpperCase()}',
      );

      expect(
        template.process(context: {
          'input': 'Hello World!',
        }),
        'HELLO WORLD!',
      );
    });

    test('trim', () {
      final template = Template(
        value: r'${input.trim()}',
      );

      expect(
        template.process(context: {
          'input': '  Hello World!  ',
        }),
        'Hello World!',
      );
    });
  });
}
