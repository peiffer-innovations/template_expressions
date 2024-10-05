library expressions.evaluator;

import 'package:json_class/json_class.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:template_expressions/expressions.dart';

import 'async_evaluator.dart';
// import 'expressions.dart';
// import 'functions/codex_functions.dart';
// import 'functions/date_time_functions.dart';
// import 'functions/duration_functions.dart';
// import 'functions/json_path_functions.dart';
import 'standard_members.dart';

export 'functions/codex_functions.dart';
export 'functions/crypto_functions.dart';
export 'functions/date_time_functions.dart';
export 'functions/duration_functions.dart';
export 'functions/encrypt_functions.dart';
export 'functions/future_functions.dart';
export 'functions/json_path_functions.dart';
export 'functions/number_functions.dart';
export 'functions/random_functions.dart';

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

  static final Map<String, Object> _delegate = {
    ...CodexFunctions.members,
    ...CryptoFunctions.functions,
    ...DateTimeFunctions.functions,
    ...DurationFunctions.functions,
    ...EncryptFunctions.functions,
    ...FutureFunctions.functions,
    ...JsonPathFunctions.functions,
    ...NumberFunctions.functions,
    ...RandomFunctions.functions,
  };

  static final Logger _logger = Logger('ExpressionEvaluator');

  final List<MemberAccessor> memberAccessors;

  dynamic eval(
    Expression expression,
    Map<String, dynamic> context, {
    void Function(String key, dynamic value)? onValueAssigned,
  }) {
    dynamic result;
    final ctx = Map<String, dynamic>.from(context);
    _delegate.forEach((key, value) => ctx.putIfAbsent(key, () => value));

    if (expression is Literal) {
      result = evalLiteral(expression, ctx);
    } else if (expression is Variable) {
      result = evalVariable(expression, ctx);
    } else if (expression is ThisExpression) {
      result = evalThis(expression, ctx);
    } else if (expression is MemberExpression) {
      result = evalMemberExpression(
        expression,
        ctx,
        nullable: expression.nullable,
      );
    } else if (expression is IndexExpression) {
      result = evalIndexExpression(
        expression,
        ctx,
        nullable: expression.nullable,
      );
    } else if (expression is CallExpression) {
      result = evalCallExpression(expression, ctx);
    } else if (expression is UnaryExpression) {
      result = evalUnaryExpression(expression, ctx);
    } else if (expression is BinaryExpression) {
      result = evalBinaryExpression(
        expression,
        ctx,
        onValueAssigned: onValueAssigned,
      );
    } else if (expression is ConditionalExpression) {
      result = evalConditionalExpression(expression, ctx);
    } else {
      throw ArgumentError(
          "Unknown expression type '${expression.runtimeType}'");
    }

    _logger.finest(
      '[eval]: evaluated.... [${expression.toTokenString()}] => [$result]',
    );
    return result;
  }

  @protected
  dynamic evalLiteral(
    Literal literal,
    Map<String, dynamic> context,
  ) {
    final value = literal.value;
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
    Map<String, dynamic> context, {
    bool nullable = false,
  }) {
    final obj = eval(expression.object, context);

    _logger.finest('[evalMemberExpression]: [${expression.property.name}]');
    return getMember(obj, expression.property.name, nullable: nullable);
  }

  @protected
  dynamic evalIndexExpression(
    IndexExpression expression,
    Map<String, dynamic> context, {
    bool nullable = false,
  }) {
    final indexed = eval(expression.object, context);

    return indexed == null && nullable
        ? null
        : indexed[eval(expression.index, context)];
  }

  @protected
  dynamic evalCallExpression(
    CallExpression expression,
    Map<String, dynamic> context,
  ) {
    final callee = eval(expression.callee, context);
    final arguments =
        expression.arguments.map((e) => eval(e, context)).toList();

    _logger.finest('[evalCallExpression]: [${expression.callee}]');

    try {
      return Function.apply(callee, arguments);
    } catch (e, stack) {
      _logger.severe(
        '[evalCallExpression]: Exception in evaluation of: [${expression.toTokenString()}]',
        e,
        stack,
      );
      rethrow;
    }
  }

  @protected
  dynamic evalUnaryExpression(
    UnaryExpression expression,
    Map<String, dynamic> context,
  ) {
    final argument = eval(expression.argument, context);
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
    Map<String, dynamic> context, {
    void Function(String key, dynamic value)? onValueAssigned,
  }) {
    dynamic result;
    final left = eval(expression.left, context);
    dynamic right() => eval(expression.right, context);
    switch (expression.operator) {
      case '=':
        final leftVar = expression.left.toString();
        result = right();
        context[leftVar] = result;
        if (onValueAssigned != null) {
          onValueAssigned(leftVar, result);
        }
        break;

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
        final r = right();
        result = left + r;
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

      case '~/':
        result = left ~/ right();
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
    final test = JsonClass.parseBool(eval(expression.test, context));
    return test
        ? eval(expression.consequent, context)
        : eval(expression.alternate, context);
  }

  @protected
  dynamic getMember(dynamic obj, String member, {bool nullable = false}) {
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

    if (!found && !nullable) {
      throw ExpressionEvaluatorException.memberAccessNotSupported(
        obj.runtimeType,
        member,
      );
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

class CustomizableMemberAccessor<T> extends _MemberAccessor<T>
    implements MemberAccessor<T> {
  CustomizableMemberAccessor(super.accessors);

  void addAccessor(
    String name,
    SingleMemberAccessor<T> accessor,
  ) =>
      accessors[name] = accessor;

  void addAccessors(Map<String, SingleMemberAccessor<T>> accessors) =>
      this.accessors.addAll(accessors);
}

abstract class MemberAccessor<T> {
  const factory MemberAccessor(Map<String, SingleMemberAccessor<T>> accessors) =
      _MemberAccessor;

  const factory MemberAccessor.fallback(AnyMemberAccessor<T> accessor) =
      _MemberAccessorFallback;

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
