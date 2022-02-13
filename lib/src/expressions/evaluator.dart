library expressions.evaluator;

import 'package:meta/meta.dart';

import 'async_evaluator.dart';
import 'expressions.dart';
import 'standard_members.dart';

/// Handles evaluation of expressions
///
/// The default [ExpressionEvaluator] handles all expressions except member
/// expressions. To create an [ExpressionEvaluator] that handles member
/// expressions, set a list of [MemberAccessor] instances to the
/// [memberAccessors] argument of the constructor.
///
/// For example:
///
///   var evaluator = ExpressionEvaluator(memberAccessors: [
///     MemberAccessor<Person>({
///       'firstname': (v)=>v.firstname,
///       'lastname': (v)=>v.lastname,
///       'address': (v)=>v.address
///     }),
///     MemberAccessor<Address>({
///       'street': (v)=>v.street,
///       'locality': (v)=>v.locality,
///     }),
///   ]);
///
/// The [MemberAccessor.mapAccessor] can be used to access [Map] items with
/// member access syntax.
///
/// An async [ExpressionEvaluator] can be created with the
/// [ExpressionEvaluator.async] constructor. An async expression evaluator can
/// handle operands and arguments that are streams or futures and will apply the
/// expression on each value of those streams or futures. The result is always a
/// stream.
///
/// For example:
///
///   var evaluator = ExpressionEvaluator.async();
///
///   var expression = Expression.parse('x > 70');
///
///   var r = evaluator.eval(expression, {'x': Stream.fromIterable([50, 80])});
///
///   r.forEach(print); // prints false and true
///
class ExpressionEvaluator {
  const ExpressionEvaluator({this.memberAccessors = const []});

  const factory ExpressionEvaluator.async(
      {List<MemberAccessor> memberAccessors}) = AsyncExpressionEvaluator;

  final List<MemberAccessor> memberAccessors;

  dynamic eval(
    Expression expression,
    Map<String, dynamic> context,
  ) {
    dynamic result;

    if (expression is Literal) {
      result = evalLiteral(expression, context);
    } else if (expression is Variable) {
      result = evalVariable(expression, context);
    } else if (expression is ThisExpression) {
      result = evalThis(expression, context);
    } else if (expression is MemberExpression) {
      result = evalMemberExpression(expression, context);
    } else if (expression is IndexExpression) {
      result = evalIndexExpression(expression, context);
    } else if (expression is CallExpression) {
      result = evalCallExpression(expression, context);
    } else if (expression is UnaryExpression) {
      result = evalUnaryExpression(expression, context);
    } else if (expression is BinaryExpression) {
      result = evalBinaryExpression(expression, context);
    } else if (expression is ConditionalExpression) {
      result = evalConditionalExpression(expression, context);
    } else {
      throw ArgumentError(
          "Unknown expression type '${expression.runtimeType}'");
    }
    return result;
  }

  @protected
  dynamic evalLiteral(
    Literal literal,
    Map<String, dynamic> context,
  ) {
    var value = literal.value;
    dynamic result = value;

    if (value is List) {
      result = value.map((e) => eval(e, context)).toList();
    } else if (value is Map) {
      result = value.map(
          (key, value) => MapEntry(eval(key, context), eval(value, context)));
    }
    return result;
  }

  @protected
  dynamic evalVariable(
    Variable variable,
    Map<String, dynamic> context,
  ) {
    return context[variable.identifier.name];
  }

  @protected
  dynamic evalThis(
    ThisExpression expression,
    Map<String, dynamic> context,
  ) {
    return context['this'];
  }

  @protected
  dynamic evalMemberExpression(
    MemberExpression expression,
    Map<String, dynamic> context,
  ) {
    var obj = eval(expression.object, context);

    return getMember(obj, expression.property.name);
  }

  @protected
  dynamic evalIndexExpression(
    IndexExpression expression,
    Map<String, dynamic> context,
  ) {
    return eval(expression.object, context)[eval(expression.index, context)];
  }

  @protected
  dynamic evalCallExpression(
    CallExpression expression,
    Map<String, dynamic> context,
  ) {
    var callee = eval(expression.callee, context);
    var arguments = expression.arguments.map((e) => eval(e, context)).toList();
    return Function.apply(callee, arguments);
  }

  @protected
  dynamic evalUnaryExpression(
    UnaryExpression expression,
    Map<String, dynamic> context,
  ) {
    var argument = eval(expression.argument, context);
    dynamic result;
    switch (expression.operator) {
      case '-':
        result = -argument;
        break;

      case '+':
        result = argument;
        break;

      case '!':
        result = !argument;
        break;

      case '~':
        result = ~argument;
        break;

      default:
        throw ArgumentError('Unknown unary operator ${expression.operator}');
    }

    return result;
  }

  @protected
  dynamic evalBinaryExpression(
    BinaryExpression expression,
    Map<String, dynamic> context,
  ) {
    dynamic result;
    var left = eval(expression.left, context);
    var right = () => eval(expression.right, context);
    switch (expression.operator) {
      case '||':
        result = left || right();
        break;

      case '&&':
        result = left && right();
        break;

      case '|':
        result = left | right();
        break;

      case '^':
        result = left ^ right();
        break;

      case '&':
        result = left & right();
        break;

      case '==':
        result = left == right();
        break;

      case '!=':
        result = left != right();
        break;

      case '<=':
        result = left <= right();
        break;

      case '>=':
        result = left >= right();
        break;

      case '<':
        result = left < right();
        break;

      case '>':
        result = left > right();
        break;

      case '<<':
        result = left << right();
        break;

      case '>>':
        result = left >> right();
        break;

      case '+':
        result = left + right();
        break;

      case '-':
        result = left - right();
        break;

      case '*':
        result = left * right();
        break;

      case '/':
        result = left / right();
        break;

      case '%':
        result = left % right();
        break;

      case '??':
        result = left ?? right();
        break;

      default:
        throw ArgumentError(
          'Unknown operator ${expression.operator} in expression',
        );
    }

    return result;
  }

  @protected
  dynamic evalConditionalExpression(
    ConditionalExpression expression,
    Map<String, dynamic> context,
  ) {
    var test = eval(expression.test, context);
    return test
        ? eval(expression.consequent, context)
        : eval(expression.alternate, context);
  }

  @protected
  dynamic getMember(
    dynamic obj,
    String member,
  ) {
    var found = false;
    dynamic result;

    for (var a in memberAccessors) {
      if (a.canHandle(obj, member)) {
        result = a.getMember(obj, member);
        found = true;
        break;
      }
    }

    if (!found) {
      try {
        result = lookupStandardMembers(obj, member);
        if (result != null) {
          found = true;
        }
      } catch (e) {
        // no-op
      }
    }

    if (!found) {
      throw ExpressionEvaluatorException.memberAccessNotSupported(
          obj.runtimeType, member);
    }

    return result;
  }
}

class ExpressionEvaluatorException implements Exception {
  ExpressionEvaluatorException(this.message);

  ExpressionEvaluatorException.memberAccessNotSupported(
      Type type, String member)
      : this(
            'Access of member `$member` not supported for objects of type `$type`: have you defined a member accessor in the ExpressionEvaluator?');

  final String message;

  @override
  String toString() => 'ExpressionEvaluatorException: $message';
}

typedef SingleMemberAccessor<T> = dynamic Function(T);
typedef AnyMemberAccessor<T> = dynamic Function(T, String member);

abstract class MemberAccessor<T> {
  const factory MemberAccessor(Map<String, SingleMemberAccessor<T>> accessors) =
      _MemberAccessor;

  const factory MemberAccessor.fallback(AnyMemberAccessor<T> accessor) =
      _MemberAccessorFallback;

  static const MemberAccessor<Map> mapAccessor =
      MemberAccessor<Map>.fallback(_getMapItem);

  static dynamic _getMapItem(Map map, String key) => map[key];

  dynamic getMember(T object, String member);

  bool canHandle(dynamic object, String member);
}

class _MemberAccessorFallback<T> implements MemberAccessor<T> {
  const _MemberAccessorFallback(this.accessor);

  final AnyMemberAccessor<T> accessor;

  @override
  bool canHandle(object, String member) => (object is T) ? true : false;

  @override
  dynamic getMember(T object, String member) => accessor(object, member);
}

class _MemberAccessor<T> implements MemberAccessor<T> {
  const _MemberAccessor(this.accessors);

  final Map<String, SingleMemberAccessor<T>> accessors;

  @override
  bool canHandle(object, String member) =>
      (object is! T) ? false : (accessors.containsKey(member) ? true : false);

  @override
  dynamic getMember(T object, String member) => accessors[member]!(object);
}
