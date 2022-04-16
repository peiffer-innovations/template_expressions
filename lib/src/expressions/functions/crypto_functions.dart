import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Class that contains functions related to the crypto package.
class CryptoFunctions {
  /// The functions related to the crypto package.
  static final functions = {
    'hmac': (key, message) =>
        Hmac(sha256, key is String ? base64.decode(key) : key)
            .convert(message is String ? utf8.encode(message) : message)
            .toString(),
    'hmac256': (key, message) =>
        Hmac(sha256, key is String ? base64.decode(key) : key)
            .convert(message is String ? utf8.encode(message) : message)
            .toString(),
    'hmac512': (key, message) =>
        Hmac(sha512, key is String ? base64.decode(key) : key)
            .convert(message is String ? utf8.encode(message) : message)
            .toString(),
    'md5': (content) => md5
        .convert(content is String ? utf8.encode(content) : content)
        .toString(),
    'sha': (content) => sha256
        .convert(content is String ? utf8.encode(content) : content)
        .toString(),
    'sha256': (content) => sha256
        .convert(content is String ? utf8.encode(content) : content)
        .toString(),
    'sha512': (content) => sha512
        .convert(content is String ? utf8.encode(content) : content)
        .toString(),
  };
}
