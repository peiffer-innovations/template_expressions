import 'dart:math';

import 'package:petitparser/petitparser.dart';
import 'package:template_expressions/expressions.dart';
import 'package:template_expressions/src/expressions/parser.dart';
import 'package:test/test.dart';

void main() {
  group('parse', () {
    final parser = ExpressionParser();

    test('identifier', () {
      for (var v in ['foo', '_value', r'$x1']) {
        expect(parser.identifier.end().parse(v).value.name, v);
      }

      for (var v in ['1', '-qdf', '.sfd']) {
        expect(parser.identifier.end().parse(v).isSuccess, isFalse);
      }
    });

    test('numeric literal', () {
      for (var v in ['134', '.5', '43.2', '1e3', '1E-3', '1e+0', '0x01']) {
        final w = parser.numericLiteral.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.value, num.parse(v));
        expect(w.value.raw, v);
      }

      for (var v in [
        '-134',
        '.5.4',
        '1e5E3',
      ]) {
        expect(parser.numericLiteral.end().parse(v).isSuccess, isFalse);
      }
    });

    test('string literal', () {
      for (var v in <String>[
        "'qf sf q'",
        "'qfqsd\"qsfd'",
        "'qsd\\nfqs\\'qsdf'",
        '"qf sf q"',
        '"qfqsd\'qsfd"',
        '"qsdf\\tqs\\"qsdf"',
      ]) {
        final w = parser.stringLiteral.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.value, parser.unescape(v.substring(1, v.length - 1)));
        expect(w.value.raw, v);
      }

      for (var v in [
        "sd'<sdf'",
        "'df'sdf'",
      ]) {
        expect(parser.stringLiteral.end().parse(v).isSuccess, isFalse);
      }
    });
    test('bool literal', () {
      for (var v in <String>['true', 'false']) {
        final w = parser.boolLiteral.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.value, v == 'true');
        expect(w.value.raw, v);
      }

      for (var v in ['True', 'False']) {
        expect(parser.boolLiteral.end().parse(v).isSuccess, isFalse);
      }
    });

    test('null literal', () {
      for (var v in <String>['null']) {
        final w = parser.nullLiteral.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.value, isNull);
        expect(w.value.raw, v);
      }

      for (var v in ['NULL']) {
        expect(parser.nullLiteral.end().parse(v).isSuccess, isFalse);
      }
    });

    test('this literal', () {
      for (var v in <String>['this']) {
        final w = parser.thisExpression.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value, isA<ThisExpression>());
      }
    });

    test('map literal', () {
      for (var e in {
        '{"hello": 1, "world": 2}': {
          Literal('hello'): Literal(1),
          Literal('world'): Literal(2),
        },
        '{}': {}
      }.entries) {
        final v = e.key;
        final w = parser.mapLiteral.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.value, e.value);
        expect(w.value.raw, v);
      }
    });

    test('array literal', () {
      for (var e in {
        '[1, 2, 3]': [Literal(1), Literal(2), Literal(3)],
        '[]': []
      }.entries) {
        final v = e.key;
        final w = parser.arrayLiteral.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.value, e.value);
        expect(w.value.raw, v);
      }

      for (var v in ['[1,2[']) {
        expect(parser.arrayLiteral.end().parse(v).isSuccess, isFalse);
      }
    });

    test('token', () {
      for (var v in <String>[
        'x',
        '_qsdf',
        'x.y',
        'a[1]',
        'a.b[c]',
        'f(1, 2)',
        '(a+B).x',
        'foo.bar(baz)',
        '1',
        '"abc"',
        '(a%2)'
      ]) {
        final w = parser.token.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.toTokenString(), v);
      }
    });

    test('binary expression', () {
      for (var v in <String>[
        '1',
        '1+2',
        'a+b*2-Math.sqrt(2)',
        '-1+2',
        '1+4-5%2*5<4==(2+1)*1<=2&&2||2'
      ]) {
        final w = parser.binaryExpression.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.toString(), v);
      }
    });

    test('unary expression', () {
      for (var v in <String>['+1', '-a', '!true', '~0x01']) {
        final w = parser.unaryExpression.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.toString(), v);
      }
    });

    test('conditional expression', () {
      for (var v in <String>["1<2 ? 'always' : 'never'"]) {
        final w = parser.expression.end().parse(v);
        expect(w.isSuccess, isTrue, reason: 'Failed parsing `$v`');
        expect(w.value.toString(), v);
      }
    });
  });

  group('evaluation', () {
    const evaluator = ExpressionEvaluator();

    test('assignment', () {
      final context = <String, dynamic>{};
      final parsed = Expression.parse('x = 1 + 2 * 3');
      expect(
        evaluator.eval(
          parsed,
          context,
          onValueAssigned: (name, value) => context[name] = value,
        ),
        7,
      );

      expect(context['x'], 7);
    });

    test('nested functions', () {
      final parsed = Expression.parse(
        'add(add(0, 1), add(2, add(3, add(4, 5))))',
      );

      expect(
        evaluator.eval(parsed, {
          'add': (a, b) => a + b,
        }),
        15,
      );
    });

    test('dynamic args', () {
      final context = {
        'add': (a, [b, c, d, e, f]) =>
            a + (b ?? 0) + (c ?? 0) + (d ?? 0) + (e ?? 0) + (f ?? 0),
      };
      final expressions = {
        'add(0, 1, 2, 3, 4, 5)': 15,
        'add(0, 1, 2, 3)': 6,
        'add(0)': 0,
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('math and logical expressions', () {
      final context = {'x': 3, 'y': 4, 'z': 5};
      final expressions = {
        '1+2': 3,
        '-1+2': 1,
        '1+4-5%2*3': 2,
        'x*x+y*y==z*z': true
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('index expressions', () {
      final context = {
        'l': [1, 2, 3],
        'm': {
          'x': 3,
          'y': 4,
          'z': 5,
          's': [null]
        }
      };
      final expressions = {'l[1]': 2, "m['z']": 5, 'm["s"][0]': null};

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('call expressions', () {
      final context = {
        'x': 3,
        'y': 4,
        'z': 5,
        'sqrt': sqrt,
        'sayHi': () => 'hi',
      };
      final expressions = {'sqrt(x*x+y*y)': 5, 'sayHi()': 'hi'};

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('conditional expressions', () {
      final context = {'this': [], 'other': {}};
      final expressions = {"this==other ? 'same' : 'different'": 'different'};

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('array expression', () {
      final context = <String, dynamic>{};
      final expressions = {
        '[1,2,3]': [1, 2, 3]
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('map expression', () {
      final context = <String, dynamic>{};
      final expressions = {
        '{"hello": "world"}': {'hello': 'world'}
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('string concat', () {
      final context = {'a': 'alice', 'b': 'bob'};
      final expressions = {
        'a + b': 'alicebob',
        'a + " " + b': 'alice bob',
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('bool members', () {
      final context = {
        't': true,
        'f': false,
      };
      final expressions = {
        't.toString()': 'true',
        'f.toString()': 'false',
        't.toString() + " " + f.toString()': 'true false',
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('iterable members', () {
      final context = {
        'list': ['one', 'two', 'three', 'three'],
        'set': {'a', 'b', 'c'},
        'empty': [],
      };
      final expressions = {
        'empty.isEmpty': true,
        'set.isEmpty': false,
        'list.skip(1).take(2).join(",")': 'two,three',
        'list.sort().join("|")': 'one|three|three|two',
        'set.toList().reversed': ['c', 'b', 'a'],
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('map members', () {
      final context = {
        'map': {
          'a': 'one',
          'b': 'two',
          'c': 'three',
        },
        'empty': <String, String>{},
      };
      final expressions = {
        'empty.isEmpty': true,
        'map.isEmpty': false,
        'map.keys.toList()': ['a', 'b', 'c'],
        'map.values.toList()': ['one', 'two', 'three'],
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('num members', () {
      final context = {
        'one': 1,
        'onepone': 1.1,
        'two': 2,
        'minus1p1': -1.1,
        'infinity': double.infinity,
      };
      final expressions = {
        'one.isNegative': false,
        'minus1p1.isNegative': true,
        'one.toInt()': 1,
        'one.toDouble()': 1.0,
        'onepone.toInt()': 1,
        'onepone.toDouble()': 1.1,
        'onepone.round()': 1,
        'infinity.isNaN': false,
        'infinity.isFinite': false,
        'infinity.isInfinite': true,
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('string members', () {
      final context = {
        'a': 'Alice',
        'b': 'Bob',
        'commas': 'a,b,c',
        'empty': '',
        'padded': '  padded  ',
      };
      final expressions = {
        'a.toUpperCase()': 'ALICE',
        'b.toLowerCase()': 'bob',
        'a.compareTo(b).isNegative': true,
        'a.isEmpty': false,
        'commas.split(",")': ['a', 'b', 'c'],
        'commas.split(",")[1]': 'b',
        'commas.split(",").join("|")': 'a|b|c',
        'empty.isEmpty': true,
        'a.substring(2, 3) + b.substring(1,2)': 'io',
        '(a.substring(2, 3) + b.substring(1,2)).toUpperCase()': 'IO',
        'padded.trim()': 'padded',
        'padded.trimLeft()': 'padded  ',
        'padded.trimRight()': '  padded',
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    test('null operator expression', () {
      final context = {'x': 3, 'y': 4, 'z': null};
      final expressions = {
        'x ?? y': 3,
        'z ?? y': 4,
        'x + (z ?? y)': 7,
        'x + (x ?? y)': 6,
      };

      expressions.forEach((e, r) {
        expect(evaluator.eval(Expression.parse(e), context), r);
      });
    });

    group('member expressions', () {
      test('toString member', () {
        final evaluator = ExpressionEvaluator(memberAccessors: [
          MemberAccessor<Object?>({'toString': (v) => v.toString})
        ]);

        final expression = Expression.parse('x.toString()');

        expect(evaluator.eval(expression, {'x': null}), 'null');
        expect(evaluator.eval(expression, {'x': 1}), '1');
        expect(evaluator.eval(expression, {'x': true}), 'true');
        expect(evaluator.eval(expression, {'x': DateTime(2020, 1, 1)}),
            '2020-01-01 00:00:00.000');
      });

      test('Uri members', () {
        final evaluator = ExpressionEvaluator(memberAccessors: [
          MemberAccessor<Uri>({
            'host': (v) => v.host,
            'isScheme': (v) => v.isScheme,
            'path': (v) => v.path,
            'replace': (v) => (map) => v.replace(
                  fragment: map['fragment'],
                  host: map['host'],
                  path: map['path'],
                  pathSegments: map['pathSegments'],
                  port: map['port'],
                  query: map['query'],
                  queryParameters: map['queryParameters'],
                  scheme: map['scheme'],
                  userInfo: map['userInfo'],
                ),
            'scheme': (v) => v.scheme,
            'queryParameters': (v) => v.queryParameters,
          })
        ]);

        final context = {'x': Uri.parse('http://localhost/index.html?lang=nl')};

        expect(
            evaluator.eval(Expression.parse('x.host'), context), 'localhost');
        expect(
          evaluator.eval(Expression.parse('x.isScheme("HTTP")'), context),
          true,
        );
        expect(
          evaluator.eval(
              Expression.parse('x.replace({"scheme": "https"}).scheme'),
              context),
          'https',
        );
        expect(
            evaluator.eval(Expression.parse('x.path'), context), '/index.html');
        expect(evaluator.eval(Expression.parse('x.scheme'), context), 'http');
        expect(evaluator.eval(Expression.parse('x.queryParameters'), context),
            {'lang': 'nl'});
      });

      test('Map members', () {
        const evaluator =
            ExpressionEvaluator(memberAccessors: [MemberAccessor.mapAccessor]);

        final context = {
          'x': {'y': 1, 'z': 2}
        };

        expect(evaluator.eval(Expression.parse('x.y'), context), 1);
        expect(evaluator.eval(Expression.parse('x.z'), context), 2);
      });
    });
  });

  group('failure handling', () {
    test('Expression.parse() throws on an invalid expression', () {
      expect(() => Expression.parse('5 1 6'), throwsA(isA<ParserException>()));
    });

    test('Expression.tryParse() returns null on an invalid expression', () {
      expect(Expression.tryParse('5 1 6'), null);
    });
  });
}
