import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
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
