import 'dart:math' as math;
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:template_expressions/template_expressions.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('${record.stackTrace}');
    }
  });

  group('aes', () {
    test('encrypt / decrypt', () {
      var key = SecureRandom(256 ~/ 8);

      var context = {
        'data': 'Hello World!',
        'key': key,
      };

      var encrypted = Template(
        value: r'${AES().key(key).encrypt(data)}',
      ).process(
        context: context,
      );

      expect(encrypted != context['data'], true);

      var decrypted = Template(
        value: '\${AES().key(key).decrypt("$encrypted").toString()}',
      ).process(context: context);

      expect(decrypted, context['data']);
    });

    test('encrypt / decrypt: string key', () {
      var context = {
        'data': 'Hello World!',
        'iv': _kIV,
        'key': _kAesKey,
      };

      var encrypted = Template(
        value: r'${AES().key(key).iv(iv).encrypt(data)}',
      ).process(
        context: context,
      );

      var parts = encrypted.split(':');

      expect(parts[0], _kIV);
      expect(encrypted, 'UPiAY93c6VgQyiTc8mXzzg==:QpuT2peJ+VKBcWSLi06q4A==');

      var decrypted = Template(
        value: r'${AES().key(key).iv(iv).decrypt(encrypted).toString()}',
      ).process(context: {
        ...context,
        'encrypted': encrypted,
      });

      expect(decrypted, context['data']);
    });
  });

  group('rsa', () {
    test('encrypt / decrypt: string', () {
      var rsapars = pc.RSAKeyGeneratorParameters(BigInt.from(65537), 4096, 5);
      var params = pc.ParametersWithRandom(rsapars, _getRsaSecureRandom());
      var keyGenerator = RSAKeyGenerator();
      keyGenerator.init(params);
      var keyPair = keyGenerator.generateKeyPair();

      var context = {
        'data': 'Hello World!',
        'privateKey': keyPair.privateKey,
        'publicKey': keyPair.publicKey,
      };

      var encrypted = Template(
        value: r'${RSA().publicKey(publicKey).encrypt(data)}',
      ).process(
        context: context,
      );

      expect(encrypted != context['data'], true);

      var decrypted = Template(
        value: r'${RSA().privateKey(privateKey).decrypt(encrypted).toString()}',
      ).process(context: {
        ...context,
        'encrypted': encrypted,
      });

      expect(decrypted, context['data']);
    });

    test('encrypt / decrypt: PEM', () {
      var context = {
        'data': 'Hello PEM World!',
        'iv': _kIV,
        'key': _kAesKey,
        'privateKey': _kRsaPrivateKey,
        'publicKey': _kRsaPublicKey,
      };

      var encrypted = Template(
        value:
            r'${RSA().aes(AES().key(key).iv(iv)).publicKey(publicKey).encrypt(data)}',
      ).process(
        context: context,
      );

      var parts = encrypted.split(':');

      var aesEncrypted = '${parts[1]}:${parts[2]}';
      expect(
        parts[1],
        _kIV,
      );
      expect(
        aesEncrypted,
        'UPiAY93c6VgQyiTc8mXzzg==:TRSTeVKIA0WWMFHVHmbDQoR9dDt7jyF4SauqcMK8e6c=',
      );

      var decrypted = Template(
        value:
            r'${RSA().aes(AES().key(key).iv(iv)).privateKey(privateKey).decrypt(encrypted).toString()}',
      ).process(context: {
        ...context,
        'encrypted': encrypted,
      });

      expect(decrypted, context['data']);
    });

    test('sign / verify: PEM', () {
      var context = {
        'data': 'Hello PEM World!',
        'privateKey': _kRsaPrivateKey,
        'publicKey': _kRsaPublicKey,
      };

      var signature = Template(
        value: r'${RSA().privateKey(privateKey).sign(data).toBase64()}',
      ).process(
        context: context,
      );

      expect(
        signature,
        'NbqHGgKSYxGcZLgJeHfo4k1WGfjWqGYLmoHFehWI9jlpCdEd1nDrL1JzGsmWR1GHGQpluHBQIaF99jz739TbcJvQT9GWsu1KwdnnYozALyo9XRw2LNl1EZi5BqahPMa8ZJUXEeEx3/l55DYKt26DE3RGoAyPHmR3W0ery8VubE37CWhqaPB74rNdRHCm5cVuwnBNtn1tHk4nvdLvF/zSpr7x2xB2v6fTQ1uDq7x/XxXbl3cfeRPNY9o0Aq52vgNFGG+VnOeNp5BTNGOShQJAESmxuh5AfVEeoioQxWXa7m6UyeIp+VaVNBj2YB9IXI5U7MwKvbVoGYqEjwIO7m7zdg==',
      );

      var verified = Template(
        value: r'${RSA().publicKey(publicKey).verify(data, signature)}',
      ).process(context: {
        ...context,
        'signature': signature,
      });

      expect(verified, 'true');

      verified = Template(
        value:
            r'${RSA().publicKey(publicKey).verify("Hellow World!", signature)}',
      ).process(context: {
        ...context,
        'signature': signature,
      });

      expect(verified, 'false');
    });
  });
}

pc.SecureRandom _getRsaSecureRandom() {
  var secureRandom = FortunaRandom();
  var random = math.Random.secure();
  var seeds = <int>[];
  for (var i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

const _kAesKey = 'Ag9prZsb9QrzNWb1/fx1zjHPMQ/EY0iaXDRJZPjDJSw=';

const _kIV = 'UPiAY93c6VgQyiTc8mXzzg==';

const _kRsaPrivateKey = '''
-----BEGIN RSA PRIVATE KEY-----
MIIFowIBAAKCAQEAjs78njX6GZT/6OcD06BVFz7N8IpfR1Fl+lt+0KXQCMpKlj8BX5GNvFwU
+ob5hgtcZQ17NoF5apNmu+vvTwTjinMtFn2Y4DRbktsHyAdv3dlaVYbQXwdTAoHx6VtJKEM7
Hdps2kD5J/vf0JxOeKjI+PnoFdhWWKgRhgSA7SN6wuAirQPgzSlS8Nk1ZNzjqDLXykJPAnoz
rvupVVRiSh5WpFuiL8btG9m0+T3AyiKvj/kcAVIJ4GDTa6xwkdSgTA+VIbdH2ULN9ykiP2x8
PtbFIcf7qxlySyVxIP9N3+WUuT1czTNOROkObN6E6YjOGtBAOAK45zbtPXMnN5RH/GDZqwKC
AQAUR8rSQQIaffF1xtDhTeSnn3Cpl0z+mM2tpy60PMf1Z5z+B0aPpuEE/eKwzVhEM/rUEv0L
eYmfm/079L6QbzZNJBwkFIQQWv8iNN6/BmdZjxNoD/QpeqXMNl3/cMpL4HhVvf41ZIK9reRU
AM6YDgg0a3ENISLqBjwu1xbkFmTJpcp28iw9JkCiYgNIOe4t657DEGNFx42PDUcjfZHA/j1z
FKemsTv8VPs+k0XoT5jb3tWM6PUYNaswo7j4uK6WkjjGk02H5Ba0X6nNomPV/fVCioWJHq5i
rlU4u0kHRjsIir3dA7uR1obXlYN6EGYVR5/B1NzUOSSbJB64xbdL1ItJAoIBABRHytJBAhp9
8XXG0OFN5KefcKmXTP6Yza2nLrQ8x/VnnP4HRo+m4QT94rDNWEQz+tQS/Qt5iZ+b/Tv0vpBv
Nk0kHCQUhBBa/yI03r8GZ1mPE2gP9Cl6pcw2Xf9wykvgeFW9/jVkgr2t5FQAzpgOCDRrcQ0h
IuoGPC7XFuQWZMmlynbyLD0mQKJiA0g57i3rnsMQY0XHjY8NRyN9kcD+PXMUp6axO/xU+z6T
RehPmNve1Yzo9Rg1qzCjuPi4rpaSOMaTTYfkFrRfqc2iY9X99UKKhYkermKuVTi7SQdGOwiK
vd0Du5HWhteVg3oQZhVHn8HU3NQ5JJskHrjFt0vUi0kCgYEAzOcNenpJADItOWJJgl3MqiLe
GHEbPYrc3+FuV5rW0TuYtm/YcLxEECFSI8aUggIohkEFAtIj6axJpMalS6qOESHtYDEvHIa2
Czd6J+46uj2yfZPFZJZhgZwJ011J6+5kFpNsKOoi+TvMUtgAga7LhfX1t96Oq1O6/2CVj4qn
XtUCgYEAsmvcuzn4O2bv0ujE4Uft2PiV6FXvVQVRXZRySf0KHXtoYMBf9So5NRIN32zc10gf
YOs5XErsTxlxjNHg39w1lsqd+YCy09Y2WfkPeRSDozvjwl8O+LyHpQ7xhjZhnONyCFDk60X5
9933EqP6jh2UMuM4Tt+6lM8LwCwINU6oln8CgYEAyGJ9z/WfRs3LZH82nIPXD9whj42tsjYH
Y/s2yf3nb5/07RXcegPkHFI53jrqKWqq7wDPQb742CFhs/+Az8rwPNkNKDFxfVhQ2A9dK4fT
bye/Uwgc1w4qNXLAOTDWhiERSPLLqAeyREOywqHzfN/QsiWkNDk3FV5BVlbCbSqQHDECgYEA
r9iMuN4eX/VI4lZVTC8HJPODU3P2qJXQJmna5j8EzB/HtKuFJ20Q6tQ7Zfu2AFttyairZOHW
2vKZrg9gEWHIUzCo17HXDd8uvCgy7sOgJa4uAHCNoeq1yaDbu8o3FFg6GCYaKCNUhM136CBD
HfPbDvhQk7P/ARC6ZRFAmcFHeOMCgYAuFb8NJCeMqDtG836m/OhsI0fR1aHzsBETS9BjB0+q
lUoehIRiDz68FWKMKj6IOivyP2JuDFoIyDSIXk73kvJp+tRdQwpGwlPXw/XuTOC3Qj52mqXQ
Oq1ZTEqyO7yxD7mpaHHZJgPv1kkmHrb7Qp9Lylno4rjRX4rl6LGiNE2w9g==
-----END PRIVATE KEY-----''';

const _kRsaPublicKey = '''
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEAjs78njX6GZT/6OcD06BVFz7N8IpfR1Fl+lt+0KXQCMpKlj8BX5GNvFwU+ob5
hgtcZQ17NoF5apNmu+vvTwTjinMtFn2Y4DRbktsHyAdv3dlaVYbQXwdTAoHx6VtJKEM7Hdps
2kD5J/vf0JxOeKjI+PnoFdhWWKgRhgSA7SN6wuAirQPgzSlS8Nk1ZNzjqDLXykJPAnozrvup
VVRiSh5WpFuiL8btG9m0+T3AyiKvj/kcAVIJ4GDTa6xwkdSgTA+VIbdH2ULN9ykiP2x8PtbF
Icf7qxlySyVxIP9N3+WUuT1czTNOROkObN6E6YjOGtBAOAK45zbtPXMnN5RH/GDZqwIDAQAB
-----END PUBLIC KEY-----''';
