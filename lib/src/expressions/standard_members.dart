dynamic lookupStandardMembers(dynamic target, String name) {
  dynamic result;

  if (target is Iterable) {
    switch (name) {
      case 'contains':
        result = target.contains;
        break;

      case 'elementAt':
        result = target.elementAt;
        break;

      case 'first':
        result = target.first;
        break;

      case 'isEmpty':
        result = target.isEmpty;
        break;

      case 'isNotEmpty':
        result = target.isNotEmpty;
        break;

      case 'last':
        result = target.last;
        break;

      case 'length':
        result = target.length;
        break;

      case 'join':
        result = target.join;
        break;

      case 'single':
        result = target.single;
        break;

      case 'skip':
        result = target.skip;
        break;

      case 'take':
        result = target.take;
        break;

      case 'toList':
        result = target.toList;
        break;

      case 'toSet':
        result = target.toSet;
        break;
    }

    if (target is List && result == null) {
      switch (name) {
        case 'asMap':
          result = target.asMap;
          break;

        case 'reversed':
          result = target.reversed;
          break;

        case 'sort':
          result = () {
            target.sort((a, b) {
              var result = 0;

              if (a is Comparable && b is Comparable) {
                result = a.compareTo(b);
              } else if (a is num && b is num) {
                result = a < b ? -1 : (a == b ? 0 : 1);
              }

              return result;
            });

            return target;
          };
          break;
      }
    }
  } else if (target is Map) {
    switch (name) {
      case 'clear':
        result = target.clear;
        break;

      case 'containsValue':
        result = target.containsValue;
        break;

      case 'containsKey':
        result = target.containsKey;
        break;

      case 'keys':
        result = target.keys;
        break;

      case 'isEmpty':
        result = target.isEmpty;
        break;

      case 'isNotEmpty':
        result = target.isNotEmpty;
        break;

      case 'length':
        result = target.length;
        break;

      case 'remove':
        result = target.remove;
        break;

      case 'values':
        result = target.values;
        break;
    }
  } else if (target is double || target is int || target is num) {
    switch (name) {
      case 'abs':
        result = target.abs;
        break;

      case 'ceil':
        result = target.ceil;
        break;

      case 'ceilToDouble':
        result = target.ceilToDouble;
        break;

      case 'clamp':
        result = target.clamp;
        break;

      case 'compareTo':
        result = target.compareTo;
        break;

      case 'floor':
        result = target.floor;
        break;

      case 'floorToDouble':
        result = target.floorToDouble;
        break;

      case 'isFinite':
        result = target.isFinite;
        break;

      case 'isInfinite':
        result = target.isInfinite;
        break;

      case 'isNaN':
        result = target.isNaN;
        break;

      case 'isNegative':
        result = target.isNegative;
        break;

      case 'remainder':
        result = target.remainder;
        break;

      case 'round':
        result = target.round;
        break;

      case 'roundToDouble':
        result = target.roundToDouble;
        break;

      case 'sign':
        result = target.sign;
        break;

      case 'toDouble':
        result = target.toDouble;
        break;

      case 'toInt':
        result = target.toInt;
        break;

      case 'toStringAsExponential':
        result = target.toStringAsExponential;
        break;

      case 'toStringAsFixed':
        result = target.toStringAsFixed;
        break;

      case 'toStringAsPrecision':
        result = target.toStringAsPrecision;
        break;

      case 'truncate':
        result = target.truncate;
        break;

      case 'truncateToDouble':
        result = target.truncateToDouble;
        break;
    }
  } else if (target is String) {
    switch (name) {
      case 'compareTo':
        result = target.compareTo;
        break;

      case 'contains':
        result = target.contains;
        break;

      case 'endsWith':
        result = target.endsWith;
        break;

      case 'indexOf':
        result = target.indexOf;
        break;

      case 'isEmpty':
        result = target.isEmpty;
        break;

      case 'isNotEmpty':
        result = target.isNotEmpty;
        break;

      case 'lastIndexOf':
        result = target.lastIndexOf;
        break;

      case 'length':
        result = target.length;
        break;

      case 'padLeft':
        result = target.padLeft;
        break;

      case 'padRight':
        result = target.padRight;
        break;

      case 'replaceAll':
        result = target.replaceAll;
        break;

      case 'replaceFirst':
        result = target.replaceFirst;
        break;

      case 'split':
        result = target.split;
        break;

      case 'startsWith':
        result = target.startsWith;
        break;

      case 'substring':
        result = target.substring;
        break;

      case 'toLowerCase':
        result = target.toLowerCase;
        break;

      case 'toUpperCase':
        result = target.toUpperCase;
        break;

      case 'trim':
        result = target.trim;
        break;

      case 'trimLeft':
        result = target.trimLeft;
        break;

      case 'trimRight':
        result = target.trimRight;
        break;
    }
  }

  if (target != null && result == null) {
    switch (name) {
      case 'hashCode':
        result = target.hashCode;
        break;

      case 'runtimeType':
        result = target.runtimeType;
        break;

      case 'toString':
        result = target.toString;
        break;
    }
  }

  return result;
}
