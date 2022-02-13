library expressions.core;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:quiver/core.dart';
import 'parser.dart';

class Identifier {
  Identifier(this.name) {
    assert(name != 'null');
    assert(name != 'false');
    assert(name != 'true');
    assert(name != 'this');
  }

  final String name;

  @override
  String toString() => name;
}

abstract class Expression {
  String toTokenString();

  static final ExpressionParser _parser = ExpressionParser();

  static Expression? tryParse(String formattedString) {
    final result = _parser.expression.end().parse(formattedString);
    return result.isSuccess ? result.value : null;
  }

  static Expression parse(String formattedString) =>
      _parser.expression.end().parse(formattedString).value;
}

abstract class SimpleExpression implements Expression {
  @override
  String toTokenString() => toString();
}

abstract class CompoundExpression implements Expression {
  @override
  String toTokenString() => '($this)';
}

@immutable
class Literal extends SimpleExpression {
  Literal(
    this.value, [
    String? raw,
  ]) : raw = raw ?? (value is String ? '"$value"' /*TODO escape*/ : '$value');

  final dynamic value;
  final String raw;

  @override
  String toString() => raw;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(dynamic other) => other is Literal && other.value == value;
}

class Variable extends SimpleExpression {
  Variable(this.identifier);

  final Identifier identifier;

  @override
  String toString() => '$identifier';
}

class ThisExpression extends SimpleExpression {}

class MemberExpression extends SimpleExpression {
  MemberExpression(
    this.object,
    this.property,
  );

  final Expression object;

  final Identifier property;

  @override
  String toString() => '${object.toTokenString()}.$property';
}

class IndexExpression extends SimpleExpression {
  IndexExpression(
    this.object,
    this.index,
  );

  final Expression object;

  final Expression index;

  @override
  String toString() => '${object.toTokenString()}[$index]';
}

class CallExpression extends SimpleExpression {
  CallExpression(
    this.callee,
    this.arguments,
  );

  final Expression callee;
  final List<Expression> arguments;

  @override
  String toString() => '${callee.toTokenString()}(${arguments.join(', ')})';
}

class UnaryExpression extends SimpleExpression {
  UnaryExpression(
    this.operator,
    this.argument, {
    this.prefix = true,
  });

  final String operator;

  final Expression argument;

  final bool prefix;

  @override
  String toString() => '$operator$argument';
}

@immutable
class BinaryExpression extends CompoundExpression {
  BinaryExpression(
    this.operator,
    this.left,
    this.right,
  );

  final String operator;
  final Expression left;
  final Expression right;

  static int precedenceForOperator(String operator) =>
      ExpressionParser.binaryOperations[operator]!;

  int get precedence => precedenceForOperator(operator);

  @override
  int get hashCode => hash3(left, operator, right);

  @override
  bool operator ==(dynamic other) =>
      other is BinaryExpression &&
      other.left == left &&
      other.operator == operator &&
      other.right == right;

  @override
  String toString() {
    var l = (left is BinaryExpression &&
            (left as BinaryExpression).precedence < precedence)
        ? '($left)'
        : '$left';
    var r = (right is BinaryExpression &&
            (right as BinaryExpression).precedence < precedence)
        ? '($right)'
        : '$right';
    return '$l$operator$r';
  }
}

class ConditionalExpression extends CompoundExpression {
  ConditionalExpression(
    this.test,
    this.consequent,
    this.alternate,
  );

  final Expression test;
  final Expression consequent;
  final Expression alternate;

  @override
  String toString() => '$test ? $consequent : $alternate';
}
