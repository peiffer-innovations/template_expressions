/// Credit to much of the code in this file goes to:
/// https://github.com/Vanethos/flutter_rsa_generator_example/blob/master/lib/utils/rsa_key_helper.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

Future<void> main(List<String> args) async {
  final keys = _getRsaKeyPair();

  final outpath = args.isEmpty ? 'output' : args[0];

  final output = Directory(outpath);
  if (output.existsSync()) {
    output.deleteSync(recursive: true);
  }

  final publicKey = _encodePublicKeyToPemPKCS1(
    keys.publicKey as RSAPublicKey,
  );
  final privateKey = _encodePrivateKeyToPemPKCS1(
    keys.privateKey as RSAPrivateKey,
  );

  final pubKeyFile = File('${output.path}/publicKey.pem');
  pubKeyFile.createSync(recursive: true);
  pubKeyFile.writeAsStringSync(publicKey);

  final pvtKeyFile = File('${output.path}/privateKey.pem');
  pvtKeyFile.createSync(recursive: true);
  pvtKeyFile.writeAsStringSync(privateKey);

  final aesKey = encrypt.SecureRandom(256 ~/ 8);
  final aesKeyFile = File('${output.path}/aesKey.txt');
  aesKeyFile.createSync(recursive: true);
  aesKeyFile.writeAsStringSync(aesKey.base64);

  final iv = encrypt.IV.fromSecureRandom(16);
  final ivFile = File('${output.path}/iv.txt');
  ivFile.createSync(recursive: true);
  ivFile.writeAsStringSync(iv.base64);

  exit(0);
}

/// Encode Private key to PEM Format
///
/// Given [RSAPrivateKey] returns a base64 encoded [String] with standard PEM headers and footers
///
/// source: https://github.com/Vanethos/flutter_rsa_generator_example/blob/master/lib/utils/rsa_key_helper.dart
String _encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
  final dP = privateKey.privateExponent! % (privateKey.p! - BigInt.from(1));
  final dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.from(1));
  final iQ = privateKey.q!.modInverse(privateKey.p!);

  final topLevel = ASN1Sequence();

  final version = ASN1Integer(BigInt.from(0));
  final modulus = ASN1Integer(privateKey.n);
  final publicExponent = ASN1Integer(privateKey.exponent);
  final privateExponent = ASN1Integer(privateKey.privateExponent);
  final p = ASN1Integer(privateKey.p);
  final q = ASN1Integer(privateKey.q);
  final exp1 = ASN1Integer(dP);
  final exp2 = ASN1Integer(dQ);
  final co = ASN1Integer(iQ);

  topLevel.add(version);
  topLevel.add(modulus);
  topLevel.add(publicExponent);
  topLevel.add(privateExponent);
  topLevel.add(p);
  topLevel.add(q);
  topLevel.add(exp1);
  topLevel.add(exp2);
  topLevel.add(co);

  final dataBase64 = _wrap(base64.encode(topLevel.encode()));

  return '-----BEGIN RSA PRIVATE KEY-----\r\n$dataBase64\r\n-----END RSA PRIVATE KEY-----';
}

/// Encode Public key to PEM Format
///
/// Given [RSAPublicKey] returns a base64 encoded [String] with standard PEM headers and footers
String _encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
  final topLevel = ASN1Sequence();

  topLevel.add(ASN1Integer(publicKey.modulus));
  topLevel.add(ASN1Integer(publicKey.exponent));

  final bytes = topLevel.encode();

  final dataBase64 = _wrap(base64.encode(bytes));
  final pemString =
      '-----BEGIN RSA PUBLIC KEY-----\r\n$dataBase64\r\n-----END RSA PUBLIC KEY-----';
  return pemString;
}

/// Generates a [SecureRandom]
///
/// Returns [FortunaRandom] to be used in the [AsymmetricKeyPair] generation
SecureRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  final seeds = <int>[];
  for (var i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

/// Generate a [PublicKey] and [PrivateKey] pair
///
/// Returns a [AsymmetricKeyPair] based on the [RSAKeyGenerator] with custom parameters,
/// including a [SecureRandom]
AsymmetricKeyPair<PublicKey, PrivateKey> _getRsaKeyPair() {
  final rsapars = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 5);
  final params = ParametersWithRandom(rsapars, _getSecureRandom());
  final keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}

String _wrap(String str, [int length = 72]) {
  final result = StringBuffer();

  var i = 0;
  while (i < str.length) {
    final line = str.substring(i, min(i + length, str.length));
    result.write('$line\n');

    i += length;
  }

  return result.toString().trim();
}
