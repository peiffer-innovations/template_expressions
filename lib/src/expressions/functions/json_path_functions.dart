import 'package:json_path/json_path.dart';

/// Functions related to JsonPath processing.
class JsonPathFunctions {
  /// The functions related to JsonPath processing.
  static final functions = {
    'JsonPath': (value) => JsonPath(value),
    'json_path': (value, expression) {
      dynamic result;
      final values = JsonPath(expression).read(value);

      if (values.isNotEmpty) {
        result = values.first.value;
      }

      return result;
    }
  };
}
