import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:template_expressions/src/types/codex.dart';

/// Functions related to JsonPath processing.
class CodexFunctions {
  /// The functions related to JsonPath processing.
  static final members = {
    'base64': Codex(
      decoder: (value) => base64.decode(value),
      encoder: (value) => base64.encode(value),
    ),
    'base64url': Codex(
      decoder: (value) => Base64Codec.urlSafe().decode(value),
      encoder: (value) => Base64Codec.urlSafe().encode(value),
    ),
    'json': Codex(
        decoder: (value) => json.decode(value),
        encoder: (value) => json.encode(value)),
    'hex': Codex(
      decoder: (value) => hex.decode(value),
      encoder: (value) => hex.encode(value),
    ),
    'utf8': Codex(
      decoder: (value) => utf8.decode(value),
      encoder: (value) => utf8.encode(value),
    ),
  };
}
