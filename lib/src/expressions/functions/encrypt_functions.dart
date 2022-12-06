import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

/// Functions related to AES and RSA encryption.
class EncryptFunctions {
  /// The functions related to JsonPath processing.
  static final functions = {
    'AES': () => Aes(),
    'IV': _createIv,
    'RSA': () => Rsa(),
  };
}

/// Functions related to the AES encryption
class Aes {
  Uint8List? _key;
  IV? _iv;
  AESMode _mode = AESMode.cbc;
  String _padding = 'PKCS7';

  /// Decrypts the encrypted string.  This supports having a pre-set [IV] or
  /// having the [IV] encoded on the [value] by having the [value] encoded as
  /// `${base64Iv}:${base64EncryptedValue}`.
  List<int> decrypt(String value) {
    var iv = _iv;
    var encrypted = value;
    if (iv == null || value.contains(':')) {
      final parts = value.split(':');

      if (parts.length != 2) {
        throw Exception('Attempted to AES decrypt but no IV has been set.');
      }

      iv ??= IV.fromBase64(parts[0]);
      encrypted = parts[1];
    }

    final key = _key;

    if (key == null) {
      throw Exception('Attempted to AES decrypt but no key has been set.');
    }

    final encrypter = Encrypter(
      AES(
        Key(key),
        mode: _mode,
        padding: _padding,
      ),
    );

    final result = encrypter.decryptBytes(
      Encrypted(base64.decode(encrypted)),
      iv: iv,
    );

    return result;
  }

  /// Encrypts the given value.  If an [IV] was pre-set, that [IV] will be used
  /// otherwise a new random one will be created.  The resulting string will be
  /// returned in the following form: `${base64Iv}:${base64EncryptedValue}`.
  String encrypt(dynamic value) {
    List<int> bytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = value;
    } else if (value is Uint8List) {
      bytes = value.toList();
    } else if (value is String) {
      bytes = utf8.encode(value);
    } else {
      bytes = utf8.encode(value.toString());
    }

    final iv = _iv ?? _createIv();
    final key = _key;

    if (key == null) {
      throw Exception('Attempted to AES encrypt but no key has been set.');
    }

    final encrypter = Encrypter(
      AES(
        Key(key),
        mode: _mode,
        padding: _padding,
      ),
    );

    final result = encrypter.encryptBytes(bytes, iv: iv);

    return '${iv.base64}:${result.base64}';
  }

  /// Sets the [IV] for use.
  Aes iv(dynamic iv) {
    _iv = _createIv(iv);
    return this;
  }

  /// Sets the secret key on the object.
  Aes key(dynamic key) {
    if (key is SecureRandom) {
      _key = key.bytes;
    } else if (key is List<int>) {
      _key = Uint8List.fromList(key);
    } else if (key is Uint8List) {
      _key = key;
    } else if (key is String) {
      _key = base64.decode(key);
    } else {
      throw Exception('Unknown key type: [${key?.runtimeType.toString()}]');
    }

    return this;
  }

  /// Sets the AES encryption [mode].
  Aes mode(String mode) {
    switch (mode) {
      case 'cbc':
        _mode = AESMode.cbc;
        break;

      case 'cfb64':
        _mode = AESMode.cfb64;
        break;

      case 'ctr':
        _mode = AESMode.ctr;
        break;

      case 'ecb':
        _mode = AESMode.ecb;
        break;

      case 'ofb64':
        _mode = AESMode.ofb64;
        break;

      case 'ofb64Gctr':
        _mode = AESMode.ofb64Gctr;
        break;

      case 'sic':
        _mode = AESMode.sic;
        break;

      default:
        throw Exception('Unknown AES mode: [$mode]');
    }

    return this;
  }

  /// Sets the AES encryption [padding].
  Aes padding(String padding) {
    _padding = padding;

    return this;
  }
}

class Rsa {
  Aes? _aes;
  RSASignDigest _digest = RSASignDigest.SHA256;
  RSAEncoding _encoding = RSAEncoding.PKCS1;
  RSAPrivateKey? _privateKey;
  RSAPublicKey? _publicKey;

  /// Sets the [Aes] object to use when performing the encryption of the data.
  Rsa aes(Aes aes) {
    _aes = aes;

    return this;
  }

  /// Decrypts the given [value] and returns the resulting bytes.  This expects
  /// the passed in value to be of the format:
  /// `${rsaEncryptedAesKey}:${base64Iv}:${base64EncryptedValue}`
  List<int> decrypt(String value) {
    final parts = value.split(':');
    final encrypted = '${parts[1]}:${parts[2]}';

    final aes = _aes ?? Aes();

    final privateKey = _privateKey;
    if (privateKey == null) {
      throw Exception('RSA attempted to decrypt but [privateKey] is null');
    }

    final key = RSA(
      encoding: _encoding,
      privateKey: privateKey,
    ).decrypt(
      Encrypted.fromBase64(parts[0]),
    );

    final result = aes.key(key).decrypt(encrypted);

    return result;
  }

  /// Sets the [RSASignDigest] to use for signing and verifying.
  Rsa digest(dynamic digest) {
    if (digest is RSASignDigest) {
      _digest = digest;
    } else if (digest is String) {
      switch (digest) {
        case 'SHA256':
          _digest = RSASignDigest.SHA256;
          break;

        default:
          throw Exception(
            'Unknown RSA Digest value encountered: [$digest]',
          );
      }
    } else {
      throw Exception(
          'Unknown RSA Digest type: [${digest?.runtimeType.toString()}]');
    }

    return this;
  }

  /// Sets the [RSAEncoding] to use for RSA based encryption values.
  Rsa encoding(dynamic encoding) {
    if (encoding is RSAEncoding) {
      _encoding = encoding;
    } else if (encoding is String) {
      switch (encoding) {
        case 'OAEP':
          _encoding = RSAEncoding.OAEP;
          break;

        case 'PKCS1':
          _encoding = RSAEncoding.PKCS1;
          break;

        default:
          throw Exception(
            'Unknown RSA Encoding value encountered: [$encoding]',
          );
      }
    } else {
      throw Exception(
        'Unknown RSA Encoding type: [${encoding?.runtimeType.toString()}]',
      );
    }

    return this;
  }

  /// If an [Aes] object is already set, this will use that object.  Otherwise,
  /// it will...
  /// 1. Create a new [Aes] object.
  /// 2. Create a new AES key and set it on the object.
  /// 3. Create a new IV and set it on the object.
  ///
  /// Either way, next this will RSA encrypt the AES key, encrypt the [value]
  /// using the [Aes] object.
  ///
  /// The returned string will be encoded as:
  /// `${rsaEncryptedAesKey}:${base64Iv}:${base64EncryptedValue}`
  String encrypt(dynamic value) {
    List<int> bytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = value;
    } else if (value is Uint8List) {
      bytes = value.toList();
    } else if (value is String) {
      bytes = utf8.encode(value);
    } else {
      bytes = utf8.encode(value.toString());
    }

    final publicKey = _publicKey;
    if (publicKey == null) {
      throw Exception('RSA attempted to encrypt but [publicKey] is null');
    }

    final aes = _aes ?? Aes();
    final key =
        aes._key ?? SecureRandom(256 /* bits */ ~/ 8 /* bits-per-byte */).bytes;

    final result = aes.key(key).encrypt(bytes);
    final encryptedKey = RSA(
      encoding: _encoding,
      publicKey: _publicKey,
    ).encrypt(key);

    return '${encryptedKey.base64}:$result';
  }

  /// Sets the private key on this encryption object.
  Rsa privateKey(dynamic key) {
    if (key is RSAPrivateKey) {
      _privateKey = key;
    } else if (key is String) {
      _privateKey = RSAKeyParser().parse(key) as RSAPrivateKey;
    } else {
      throw Exception(
          'Unknown privateKey type: [${key?.runtimeType.toString()}]');
    }

    return this;
  }

  /// Sets the public key on this encryption object.
  Rsa publicKey(dynamic key) {
    if (key is RSAPublicKey) {
      _publicKey = key;
    } else if (key is String) {
      _publicKey = RSAKeyParser().parse(key) as RSAPublicKey;
    } else {
      throw Exception(
        'Unknown publicKey type: [${key?.runtimeType.toString()}]',
      );
    }

    return this;
  }

  /// Signs the [value] and returns the resulting byte array.
  List<int> sign(dynamic value) {
    if (_privateKey == null) {
      throw Exception(
        'RSA attempted to sign but [privateKey] is null',
      );
    }
    final signer = Signer(RSASigner(
      _digest,
      privateKey: _privateKey,
    ));

    List<int> bytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = value;
    } else if (value is Uint8List) {
      bytes = value.toList();
    } else if (value is String) {
      bytes = utf8.encode(value);
    } else {
      bytes = utf8.encode(value.toString());
    }

    return signer.signBytes(bytes).bytes.toList();
  }

  /// Verifies the [value] and the [signature].
  bool verify(dynamic value, dynamic signature) {
    if (_publicKey == null) {
      throw Exception(
        'RSA attempted to verify but [publicKey] is null',
      );
    }
    final signer = Signer(RSASigner(
      _digest,
      publicKey: _publicKey,
    ));

    List<int> bytes;
    Uint8List sigBytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = value;
    } else if (value is Uint8List) {
      bytes = value.toList();
    } else if (value is String) {
      bytes = utf8.encode(value);
    } else {
      bytes = utf8.encode(value.toString());
    }

    if (signature == null) {
      throw Exception('Required signature is null');
    } else if (signature is List<int>) {
      sigBytes = Uint8List.fromList(signature);
    } else if (signature is Uint8List) {
      sigBytes = signature;
    } else if (signature is String) {
      sigBytes = base64.decode(signature);
    } else {
      sigBytes = base64.decode(signature.toString());
    }

    return signer.verifyBytes(bytes, Encrypted(sigBytes));
  }
}

IV _createIv([dynamic value]) {
  IV iv;

  if (value is IV) {
    iv = value;
  } else if (value == null) {
    iv = IV.fromSecureRandom(16);
  } else if (value is int) {
    iv = IV.fromSecureRandom(value);
  } else if (value is List<int>) {
    iv = IV(Uint8List.fromList(value));
  } else if (value is Uint8List) {
    iv = IV(value);
  } else if (value is String) {
    iv = IV.fromBase64(value);
  } else {
    throw Exception('Unknown IV type: [${value.runtimeType}');
  }

  return iv;
}
