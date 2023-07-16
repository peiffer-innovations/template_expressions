import 'package:json_class/json_class.dart';

/// Class that contains functions related to creating Durations.
class DurationFunctions {
  /// The functions related to the Duration creation
  static final functions = {
    'Duration': (value, [hours, minutes, seconds, milliseconds]) =>
        (hours != null ||
                minutes != null ||
                seconds != null ||
                milliseconds != null)
            ? Duration(
                days: JsonClass.maybeParseInt(value) ?? 0,
                hours: JsonClass.maybeParseInt(hours) ?? 0,
                minutes: JsonClass.maybeParseInt(minutes) ?? 0,
                seconds: JsonClass.maybeParseInt(seconds) ?? 0,
                milliseconds: JsonClass.maybeParseInt(milliseconds) ?? 0,
              )
            : value is Map
                ? Duration(
                    days: JsonClass.maybeParseInt(value['days']) ?? 0,
                    hours: JsonClass.maybeParseInt(value['hours']) ?? 0,
                    minutes: JsonClass.maybeParseInt(value['minutes']) ?? 0,
                    seconds: JsonClass.maybeParseInt(value['seconds']) ?? 0,
                    milliseconds:
                        JsonClass.maybeParseInt(value['milliseconds']) ?? 0,
                  )
                : value is List
                    ? Duration(
                        days: JsonClass.maybeParseInt(
                                value.isNotEmpty ? value[0] : null) ??
                            0,
                        hours: JsonClass.maybeParseInt(
                                value.length > 1 ? value[1] : null) ??
                            0,
                        minutes: JsonClass.maybeParseInt(
                                value.length > 2 ? value[2] : null) ??
                            0,
                        seconds: JsonClass.maybeParseInt(
                                value.length > 3 ? value[3] : null) ??
                            0,
                        milliseconds: JsonClass.maybeParseInt(
                                value.length > 4 ? value[4] : null) ??
                            0,
                      )
                    : value is String || value is num
                        ? JsonClass.maybeParseDurationFromMillis(value)!
                        : throw Exception(
                            '[Duration]: expected [value] to be a Map, a List, a String, or a num but encountered: ${value?.runtimeType}',
                          ),
    'days': (value) => Duration(hours: JsonClass.maybeParseInt(value)! * 24),
    'hours': (value) => Duration(minutes: JsonClass.maybeParseInt(value)!),
    'milliseconds': (value) =>
        Duration(milliseconds: JsonClass.maybeParseInt(value)!),
    'minutes': (value) => Duration(minutes: JsonClass.maybeParseInt(value)!),
    'seconds': (value) => Duration(seconds: JsonClass.maybeParseInt(value)!),
  };
}
