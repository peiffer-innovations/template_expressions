import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:intl/intl.dart';
import 'package:json_class/json_class.dart';
import 'package:json_path/json_path.dart';
import 'package:template_expressions/template_expressions.dart';
import 'package:yaon/yaon.dart' as yaon;

/// Associates member functions from common objects for use by the expression
/// evaluator.
dynamic lookupStandardMembers(dynamic target, String name) {
  dynamic result;

  if (target is Codex) {
    result = _processCodex(target, name);
  } else if (target is DateFormat) {
    result = _processDateFormat(target, name);
  } else if (target is DateTime) {
    result = _processDateTime(target, name);
  } else if (target is Duration) {
    result = _processDuration(target, name);
  } else if (target is Iterable) {
    result = _processIterable(target, name);
  } else if (target is JsonPath) {
    result = _processJsonPath(target, name);
  } else if (target is JsonPathMatch) {
    result = _processJsonPathMatch(target, name);
  } else if (target is Map) {
    result = _processMap(target, name);
  } else if (target is MapEntry) {
    result = _processMapEntry(target, name);
  } else if (target is double || target is int || target is num) {
    result = _processNum(target, name);
  } else if (target is String) {
    result = _processString(target, name);
  } else if (target is Aes) {
    result = _processAes(target, name);
  } else if (target is Rsa) {
    result = _processRsa(target, name);
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

dynamic _processAes(Aes target, String name) {
  dynamic result;

  switch (name) {
    case 'decrypt':
      result = target.decrypt;
      break;

    case 'encrypt':
      result = target.encrypt;
      break;

    case 'iv':
      result = target.iv;
      break;

    case 'key':
      result = target.key;
      break;

    case 'mode':
      result = target.mode;
      break;

    case 'padding':
      result = target.padding;
      break;
  }

  return result;
}

dynamic _processCodex(Codex target, String name) {
  dynamic result;

  switch (name) {
    case 'decode':
      result = target.decode;
      break;

    case 'encode':
      result = target.encode;
      break;
  }

  return result;
}

dynamic _processDateFormat(DateFormat target, String name) {
  dynamic result;

  switch (name) {
    case 'format':
      result = target.format;
      break;

    case 'parse':
      result = target.parse;
      break;

    case 'parseUtc':
    case 'parseUTC':
      result = target.parseUtc;
      break;
  }

  return result;
}

dynamic _processDateTime(DateTime target, String name) {
  dynamic result;

  switch (name) {
    case 'add':
      result = (duration) => DateTime.fromMillisecondsSinceEpoch(
            target.millisecondsSinceEpoch +
                ((duration is Duration)
                    ? duration.inMilliseconds
                    : JsonClass.parseInt(duration)!),
            isUtc: target.isUtc,
          );
      break;

    case 'compareTo':
      result = target.compareTo;
      break;

    case 'isAfter':
      result = target.isAfter;
      break;

    case 'isBefore':
      result = target.isBefore;
      break;

    case 'isUtc':
      result = target.isUtc;
      break;

    case 'millisecondsSinceEpoch':
      result = target.millisecondsSinceEpoch;
      break;

    case 'subtract':
      result = (duration) => target.subtract(
            duration is Duration
                ? duration
                : Duration(milliseconds: JsonClass.parseInt(duration)!),
          );
      break;

    case 'toIso8601String':
      result = target.toIso8601String;
      break;

    case 'toLocal':
      result = target.toLocal;
      break;

    case 'toUtc':
      result = target.toUtc;
      break;
  }
  return result;
}

dynamic _processDuration(Duration target, String name) {
  dynamic result;

  switch (name) {
    case 'add':
      result = (duration) =>
          target.inMilliseconds +
          (duration is Duration
              ? duration.inMilliseconds
              : JsonClass.parseInt(duration)!);
      break;

    case 'compareTo':
      result = target.compareTo;
      break;

    case 'inDays':
      result = target.inDays;
      break;

    case 'inHours':
      result = target.inHours;
      break;

    case 'inMilliseconds':
      result = target.inMilliseconds;
      break;

    case 'inMinutes':
      result = target.inMinutes;
      break;

    case 'inSeconds':
      result = target.inSeconds;
      break;

    case 'subtract':
      result = (duration) => Duration(
            milliseconds: target.inMilliseconds -
                (duration is Duration
                    ? duration.inMilliseconds
                    : JsonClass.parseInt(duration)!),
          );
      break;
  }

  return result;
}

dynamic _processIntList(List<int> bytes, String name) {
  dynamic result;

  switch (name) {
    case 'toBase64':
      result = () => base64.encode(bytes);
      break;

    case 'toHex':
      result = () => hex.encode(bytes);
      break;

    case 'toString':
      result = () => utf8.decode(bytes);
      break;
  }

  return result;
}

dynamic _processIterable(Iterable target, String name) {
  dynamic result;

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
    result = _processList(target, name);
  }

  return result;
}

dynamic _processJsonPath(JsonPath target, String name) {
  dynamic result;

  switch (name) {
    case 'read':
      result = target.read;
      break;

    case 'readValues':
      result = target.readValues;
      break;
  }

  return result;
}

dynamic _processJsonPathMatch(JsonPathMatch target, String name) {
  dynamic result;

  switch (name) {
    case 'parent':
      result = target.parent;
      break;

    case 'path':
      result = target.path;
      break;

    case 'value':
      result = target.value;
      break;
  }

  return result;
}

dynamic _processList(List target, String name) {
  dynamic result;

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

    case 'toJson':
      result = ([padding]) {
        var indent = JsonClass.parseInt(padding) ?? 0;

        return indent == 0
            ? json.encode(target)
            : JsonEncoder.withIndent(''.padLeft(indent, ' ')).convert(target);
      };
      break;
  }

  if (result == null) {
    if (target is List<int>) {
      result = _processIntList(target, name);
    } else if (target is Uint8List) {
      result = _processIntList(target.toList(), name);
    }
  }

  return result;
}

dynamic _processMap(Map target, String name) {
  dynamic result;

  switch (name) {
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

    case 'toJson':
      result = ([padding]) {
        var indent = JsonClass.parseInt(padding) ?? 0;

        return indent == 0
            ? json.encode(target)
            : JsonEncoder.withIndent(''.padLeft(indent, ' ')).convert(target);
      };
      break;

    case 'values':
      result = target.values;
      break;
  }

  return result;
}

dynamic _processMapEntry(MapEntry target, String name) {
  dynamic result;

  switch (name) {
    case 'key':
      result = target.key;
      break;

    case 'value':
      result = target.value;
      break;
  }

  return result;
}

dynamic _processNum(num target, String name) {
  dynamic result;

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

  return result;
}

dynamic _processRsa(Rsa target, String name) {
  dynamic result;

  switch (name) {
    case 'aes':
      result = target.aes;
      break;

    case 'decrypt':
      result = target.decrypt;
      break;

    case 'encoding':
      result = target.encoding;
      break;

    case 'encrypt':
      result = target.encrypt;
      break;

    case 'privateKey':
      result = target.privateKey;
      break;

    case 'publicKey':
      result = target.publicKey;
      break;

    case 'sign':
      result = target.sign;
      break;

    case 'verify':
      result = target.verify;
      break;
  }

  return result;
}

dynamic _processString(String target, String name) {
  dynamic result;

  switch (name) {
    case 'compareTo':
      result = target.compareTo;
      break;

    case 'contains':
      result = target.contains;
      break;

    case 'decode':
      result = () => yaon.parse(target);
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

  return result;
}
