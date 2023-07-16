import 'package:intl/intl.dart';
import 'package:json_class/json_class.dart';

/// Class containing functions related to Date / Time processing.
class DateTimeFunctions {
  /// The functions related to Date / Time processing.
  static final functions = {
    'DateFormat': (format) => DateFormat(format ?? 'yyyy-MM-dd'),
    'DateTime': (value, [month, date, hour, minute, second, millisecond]) =>
        (month != null ||
                date != null ||
                hour != null ||
                minute != null ||
                second != null ||
                millisecond != null)
            ? DateTime(
                JsonClass.maybeParseInt(value) ?? 0,
                JsonClass.maybeParseInt(month) ?? 1,
                JsonClass.maybeParseInt(date) ?? 1,
                JsonClass.maybeParseInt(hour) ?? 0,
                JsonClass.maybeParseInt(minute) ?? 0,
                JsonClass.maybeParseInt(second) ?? 0,
                JsonClass.maybeParseInt(millisecond) ?? 0,
              )
            : value is Map
                ? DateTime(
                    JsonClass.maybeParseInt(value['year']) ?? 0,
                    JsonClass.maybeParseInt(value['month']) ?? 1,
                    JsonClass.maybeParseInt(value['date'] ?? value['day']) ?? 1,
                    JsonClass.maybeParseInt(value['hour']) ?? 0,
                    JsonClass.maybeParseInt(value['minute']) ?? 0,
                    JsonClass.maybeParseInt(value['second']) ?? 0,
                    JsonClass.maybeParseInt(value['milliseconds']) ?? 0,
                  )
                : value is List
                    ? DateTime(
                        JsonClass.maybeParseInt(
                                value.isNotEmpty ? value[0] : null) ??
                            0,
                        JsonClass.maybeParseInt(
                                value.length > 1 ? value[1] : null) ??
                            1,
                        JsonClass.maybeParseInt(
                                value.length > 2 ? value[2] : null) ??
                            1,
                        JsonClass.maybeParseInt(
                                value.length > 3 ? value[3] : null) ??
                            0,
                        JsonClass.maybeParseInt(
                                value.length > 4 ? value[4] : null) ??
                            0,
                        JsonClass.maybeParseInt(
                                value.length > 5 ? value[5] : null) ??
                            0,
                        JsonClass.maybeParseInt(
                                value.length > 6 ? value[6] : null) ??
                            0,
                      )
                    : (value is num || value is String)
                        ? DateTime.fromMillisecondsSinceEpoch(
                            JsonClass.maybeParseInt(value) ?? 0)
                        : value == null
                            ? DateTime.now()
                            : throw Exception(
                                '[DateTime]: expected [value] to be a Map, a List, a num, a String, or null but encountered: ${value?.runtimeType}',
                              ),
    'now': DateTime.now,
  };
}
