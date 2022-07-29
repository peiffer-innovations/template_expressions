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
  var keys = _getRsaKeyPair();

  var outpath = args.isEmpty ? 'output' : args[0];

  var output = Directory(outpath);
  if (output.existsSync()) {
    output.deleteSync(recursive: true);
  }

  var publicKey = _encodePublicKeyToPemPKCS1(
    keys.publicKey as RSAPublicKey,
  );
  var privateKey = _encodePrivateKeyToPemPKCS1(
    keys.privateKey as RSAPrivateKey,
  );

  var pubKeyFile = File('${output.path}/publicKey.pem');
  pubKeyFile.createSync(recursive: true);
  pubKeyFile.writeAsStringSync(publicKey);

  var pvtKeyFile = File('${output.path}/privateKey.pem');
  pvtKeyFile.createSync(recursive: true);
  pvtKeyFile.writeAsStringSync(privateKey);

  var aesKey = encrypt.SecureRandom(256 ~/ 8);
  var aesKeyFile = File('${output.path}/aesKey.txt');
  aesKeyFile.createSync(recursive: true);
  aesKeyFile.writeAsStringSync(aesKey.base64);

  var iv = encrypt.IV.fromSecureRandom(16);
  var ivFile = File('${output.path}/iv.txt');
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
  var dP = privateKey.privateExponent! % (privateKey.p! - BigInt.from(1));
  var dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.from(1));
  var iQ = privateKey.q!.modInverse(privateKey.p!);

  var topLevel = ASN1Sequence();

  var version = ASN1Integer(BigInt.from(0));
  var modulus = ASN1Integer(privateKey.n);
  var publicExponent = ASN1Integer(privateKey.exponent);
  var privateExponent = ASN1Integer(privateKey.privateExponent);
  var p = ASN1Integer(privateKey.p);
  var q = ASN1Integer(privateKey.q);
  var exp1 = ASN1Integer(dP);
  var exp2 = ASN1Integer(dQ);
  var co = ASN1Integer(iQ);

  topLevel.add(version);
  topLevel.add(modulus);
  topLevel.add(publicExponent);
  topLevel.add(privateExponent);
  topLevel.add(p);
  topLevel.add(q);
  topLevel.add(exp1);
  topLevel.add(exp2);
  topLevel.add(co);

  var dataBase64 = _wrap(base64.encode(topLevel.encode()));

  return '-----BEGIN RSA PRIVATE KEY-----\r\n$dataBase64\r\n-----END RSA PRIVATE KEY-----';
}

/// Encode Public key to PEM Format
///
/// Given [RSAPublicKey] returns a base64 encoded [String] with standard PEM headers and footers
String _encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
  var topLevel = ASN1Sequence();

  topLevel.add(ASN1Integer(publicKey.modulus));
  topLevel.add(ASN1Integer(publicKey.exponent));

  var bytes = topLevel.encode();

  var dataBase64 = _wrap(base64.encode(bytes));
  var pemString =
      '-----BEGIN RSA PUBLIC KEY-----\r\n$dataBase64\r\n-----END RSA PUBLIC KEY-----';
  return pemString;
}

/// Generates a [SecureRandom]
///
/// Returns [FortunaRandom] to be used in the [AsymmetricKeyPair] generation
SecureRandom _getSecureRandom() {
  var secureRandom = FortunaRandom();
  var random = Random.secure();
  var seeds = <int>[];
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
  var rsapars = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 5);
  var params = ParametersWithRandom(rsapars, _getSecureRandom());
  var keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}

String _wrap(String str, [int length = 72]) {
  var result = StringBuffer();

  var i = 0;
  while (i < str.length) {
    var line = str.substring(i, min(i + length, str.length));
    result.write('$line\n');

    i += length;
  }

  return result.toString().trim();
}
