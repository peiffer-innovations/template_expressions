import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
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

  group('Crypto', () {
    test(
      'hmac',
      () {
        var key =
            'YWFCa3hKezJNRlQrK0EhPkBrJj5oem42OlUpWCElJVlaMmM+K3RhamA7Zjk3Z1ArRkQ7K1J6bl46diRVSz03UDJwTlczeydnNWc/MmtzdlNmY3I1fUszcShnI31jITg+XlRXcXd4V0VbRntHSEFBS2grUUZUKFR6MmFaPVQqJ04=';
        var context = {'key': key};

        var template = Template(value: r'${hmac(key, "foobar")}');
        var actual = template.process(context: context);

        expect(actual,
            'e52f174665d7ad3791c2cf8d1f7ab93f654189926975c02defbe3439cdb48716');
      },
    );

    test(
      'hmac256',
      () {
        var key =
            'YWFCa3hKezJNRlQrK0EhPkBrJj5oem42OlUpWCElJVlaMmM+K3RhamA7Zjk3Z1ArRkQ7K1J6bl46diRVSz03UDJwTlczeydnNWc/MmtzdlNmY3I1fUszcShnI31jITg+XlRXcXd4V0VbRntHSEFBS2grUUZUKFR6MmFaPVQqJ04=';
        var context = {'key': key};

        var template = Template(value: r'${hmac256(key, "foobar")}');
        var actual = template.process(context: context);

        expect(actual,
            'e52f174665d7ad3791c2cf8d1f7ab93f654189926975c02defbe3439cdb48716');
      },
    );

    test(
      'hmac512',
      () {
        var key =
            'YWFCa3hKezJNRlQrK0EhPkBrJj5oem42OlUpWCElJVlaMmM+K3RhamA7Zjk3Z1ArRkQ7K1J6bl46diRVSz03UDJwTlczeydnNWc/MmtzdlNmY3I1fUszcShnI31jITg+XlRXcXd4V0VbRntHSEFBS2grUUZUKFR6MmFaPVQqJ04=';
        var context = {'key': key};

        var template = Template(value: r'${hmac512(key, "foobar")}');
        var actual = template.process(context: context);

        expect(actual,
            '1a3a8dc298ecc8c97855e29454145a2deb39a86bb56f49c2bb951c9cbd07f22abf28d868230834973fb4f87cb6121f6cbb2d4ce29f378305a5b3cd7dc8d09aad');
      },
    );

    test('md5', () {
      var template = Template(value: r'${md5("foobar")}');
      var actual = template.process();

      expect(actual, md5.convert(utf8.encode('foobar')).toString());
    });

    test('sha', () {
      var template = Template(value: r'${sha("foobar")}');
      var actual = template.process();

      expect(actual, sha256.convert(utf8.encode('foobar')).toString());
    });

    test('sha256', () {
      var template = Template(value: r'${sha256("foobar")}');
      var actual = template.process();

      expect(actual, sha256.convert(utf8.encode('foobar')).toString());
    });

    test('sha512', () {
      var template = Template(value: r'${sha512("foobar")}');
      var actual = template.process();

      expect(actual, sha512.convert(utf8.encode('foobar')).toString());
    });
  });

  group('DateTime', () {
    var context = <String, dynamic>{};
    context['year'] = 2022;

    test('Map', () {
      var template = Template(
        value: r'${DateTime({"year": year, "month": 2, "day": 07\})}',
      );
      expect(
        template.process(context: context),
        DateTime(2022, 2, 7).toString(),
      );

      template = Template(
        syntax: [MustacheExpressionSyntax()],
        value:
            '{{DateTime({"year": year, "month": 2, "day": 07, "hour": 12, "minute": 30, "second": 10, "milliseconds": 20})}}',
      );
      expect(
        template.process(context: context),
        DateTime(2022, 2, 7, 12, 30, 10, 20).toString(),
      );
    });

    test('List', () {
      var template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{DateTime([year, 2, 07, 12, 30, 10, 20])}}',
      );
      expect(
        template.process(context: context),
        DateTime(2022, 2, 7, 12, 30, 10, 20).toString(),
      );
    });

    test('params', () {
      var template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{DateTime(year, 02)}}',
      );
      expect(
        template.process(context: context),
        DateTime(2022, 02).toString(),
      );

      template = Template(
        syntax: [MustacheExpressionSyntax()],
        value: '{{DateTime(year, 2, 07, 12, 30, 10, 20)}}',
      );
      expect(
        template.process(context: context),
        DateTime(2022, 2, 7, 12, 30, 10, 20).toString(),
      );
    });

    test('epoch millis', () {
      var template = Template(
        value: r'${DateTime(1645412678503)}',
      );
      expect(
        template.process(context: context),
        DateTime.fromMillisecondsSinceEpoch(1645412678503).toString(),
      );
    });

    test('formatting', () {
      var template = Template(
        value: r'${DateFormat("yyyy-MM-dd").parse("2022-02-07").add(days(1))}',
      );
      expect(
        template.process(context: context),
        DateTime(2022, 2, 8).toString(),
      );

      template = Template(
        value:
            r'${DateFormat("yyyy-MM-dd").format(DateTime([2022, 02, 07]).toLocal())}',
      );
      expect(
        template.process(context: context),
        '2022-02-07',
      );
    });

    test('now', () {
      var now = DateTime.now();
      var customContext = <String, dynamic>{};
      customContext['now'] = () => now;
      var template = Template(
        value: r'${now().subtract(Duration({"days": 1\})).toUtc()}',
      );
      expect(
        template.process(context: customContext),
        now.subtract(Duration(days: 1)).toUtc().toString(),
      );

      template = Template(
        value: r'${now().subtract(days(1)).toUtc()}',
      );
      expect(
        template.process(context: customContext),
        now.subtract(Duration(days: 1)).toUtc().toString(),
      );
    });
  });

  group('Duration', () {
    test('Map', () {
      var context = <String, dynamic>{};
      ;

      var template = Template(
        value:
            r'${Duration({"days": 1, "hours": 2, "minutes": 3, "seconds": 4, "milliseconds": 5\})}',
      );
      expect(
        template.process(context: context),
        Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
        ).toString(),
      );
    });

    test('List', () {
      var context = <String, dynamic>{};
      ;

      var template = Template(
        value: r'${Duration([1, 2, 3, 4, 5])}',
      );
      expect(
        template.process(context: context),
        Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
        ).toString(),
      );
    });

    test('Params', () {
      var context = <String, dynamic>{};
      ;

      var template = Template(
        value: r'${Duration(1, 2, 3, 4, 5)}',
      );
      expect(
        template.process(context: context),
        Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
        ).toString(),
      );
    });

    test('millis', () {
      var context = <String, dynamic>{};

      var template = Template(
        value: r'${Duration(1001)}',
      );
      expect(
        template.process(context: context),
        Duration(
          seconds: 1,
          milliseconds: 1,
        ).toString(),
      );
    });
  });

  group('JsonPath', () {
    var context = {
      'person': {
        'name': {
          'first': 'John',
          'last': 'Doe',
        },
      },
    };
    test('JsonPath', () {
      var template = Template(
        value:
            r'${JsonPath("$.name.first").read(person).first.value + " " + JsonPath("$.name.last").read(person).first.value}',
      );

      expect(
        template.process(context: context),
        'John Doe',
      );
    });

    test('json_path', () {
      var template = Template(
        value:
            r'${json_path(person, "$.name.first").toUpperCase() + " " + json_path(person, "$.name.last").toUpperCase()}',
      );

      expect(
        template.process(context: context),
        'JOHN DOE',
      );
    });

    test('json_path simple', () {
      var template = Template(
        value: r"${json_path(person, '$.name.first')}",
      );

      expect(
        template.process(context: context),
        'John',
      );
    });
  });

  group('List<int>', () {
    var input = 'Hello, World!';

    test('toBase64', () {
      expect(
        Template(value: r'${input.toBase64()}').process(
          context: {'input': utf8.encode(input)},
        ),
        base64.encode(utf8.encode(input)),
      );
    });

    test('toHex', () {
      expect(
        Template(value: r'${input.toHex()}').process(
          context: {'input': utf8.encode(input)},
        ),
        hex.encode(utf8.encode(input)),
      );
    });

    test('toString', () {
      expect(
        Template(value: r'${input.toString()}').process(
          context: {'input': utf8.encode(input)},
        ),
        input,
      );
    });
  });

  group('random', () {
    test('int', () {
      var template = Template(
        value: r'${random(100)}',
      );

      var processed = int.parse(template.process());

      expect(processed >= 0 && processed < 100, true);
    });

    test('double', () {
      var template = Template(
        value: r'${random()}',
      );

      var processed = double.parse(template.process());

      expect(processed >= 0.0 && processed < 1.0, true);
    });
  });
}
