import 'package:json_class/json_class.dart';

/// Class that contains functions related to creating Durations.
class DurationFunctions {
  /// The functions related to the Duration creation
  static final functions = {
    'Duration': (value, [hours, minutes, seconds, milliseconds]) => (hours !=
                null ||
            minutes != null ||
            seconds != null ||
            milliseconds != null)
        ? Duration(
            days: JsonClass.parseInt(value) ?? 0,
            hours: JsonClass.parseInt(hours) ?? 0,
            minutes: JsonClass.parseInt(minutes) ?? 0,
            seconds: JsonClass.parseInt(seconds) ?? 0,
            milliseconds: JsonClass.parseInt(milliseconds) ?? 0,
          )
        : value is Map
            ? Duration(
                days: JsonClass.parseInt(value['days']) ?? 0,
                hours: JsonClass.parseInt(value['hours']) ?? 0,
                minutes: JsonClass.parseInt(value['minutes']) ?? 0,
                seconds: JsonClass.parseInt(value['seconds']) ?? 0,
                milliseconds: JsonClass.parseInt(value['milliseconds']) ?? 0,
              )
            : value is List
                ? Duration(
                    days: JsonClass.parseInt(
                            value.isNotEmpty ? value[0] : null) ??
                        0,
                    hours: JsonClass.parseInt(
                            value.length > 1 ? value[1] : null) ??
                        0,
                    minutes: JsonClass.parseInt(
                            value.length > 2 ? value[2] : null) ??
                        0,
                    seconds: JsonClass.parseInt(
                            value.length > 3 ? value[3] : null) ??
                        0,
                    milliseconds: JsonClass.parseInt(
                            value.length > 4 ? value[4] : null) ??
                        0,
                  )
                : value is String || value is num
                    ? JsonClass.parseDurationFromMillis(value)!
                    : throw Exception(
                        '[Duration]: expected [value] to be a Map, a List, a String, or a num but encountered: ${value?.runtimeType}',
                      ),
    'days': (value) => Duration(hours: JsonClass.parseInt(value)! * 24),
    'hours': (value) => Duration(minutes: JsonClass.parseInt(value)!),
    'milliseconds': (value) =>
        Duration(milliseconds: JsonClass.parseInt(value)!),
    'minutes': (value) => Duration(minutes: JsonClass.parseInt(value)!),
    'seconds': (value) => Duration(seconds: JsonClass.parseInt(value)!),
  };
}
