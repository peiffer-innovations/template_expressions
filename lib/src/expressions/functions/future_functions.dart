import 'package:json_class/json_class.dart';

/// Class that contains functions related to working with [Future].  As a note,
/// when using these functions, be sure to use the [AsyncExpressionEvaluator]
class FutureFunctions {
  /// The functions related to working with a Future
  static final functions = {
    'await': (value) => value is Future
        ? value
        : throw Exception(
            '[await]: expected [value] to be a Future but encountered: ${value?.runtimeType}',
          ),
    'delay': (value) => value is Duration
        ? Future.delayed(value)
        : value is String || value is num
            ? Future.delayed(JsonClass.parseDurationFromMillis(value)!)
            : throw Exception(
                '[delay]: expected [value] to be a Duration, a String, or a num but encountered: ${value?.runtimeType}',
              ),
    'delayed': (value) => value is Duration
        ? Future.delayed(value)
        : value is String || value is num
            ? Future.delayed(JsonClass.parseDurationFromMillis(value)!)
            : throw Exception(
                '[delayed]: expected [value] to be a Duration, a String, or a num but encountered: ${value?.runtimeType}',
              ),
  };
}
