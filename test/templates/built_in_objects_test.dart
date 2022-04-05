import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
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
  });
}
