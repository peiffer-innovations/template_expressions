import 'dart:math';

/// Class that contains functions related generating random numbers.
class RandomFunctions {
  /// The functions related to the Random number generator
  static final functions = {
    'random': ([value]) {
      final sr = Random.secure();
      num result;

      if (value is num) {
        result = sr.nextInt(value.toInt());
      } else {
        result = sr.nextDouble();
      }

      return result;
    },
  };
}
