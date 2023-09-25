import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/block/modes/cbc.dart';

class CryptoUtil {
  static final _key = _generateRandomBytes(32);

  static Uint8List get _iv => _generateRandomBytes(16);

  static String encrypt(String plainText) {
    final params = ParametersWithIV<KeyParameter>(KeyParameter(_key), _iv);
    final blockCipher = CBCBlockCipher(AESEngine())
      ..init(true, params); // true means encrypt

    final plainData = utf8.encode(plainText) as Uint8List;
    final paddedData = _pad(plainData, blockCipher.blockSize);

    final encryptedData = _processCipher(paddedData, blockCipher);
    return '${base64Encode(encryptedData)}:${base64Encode(_iv)}';
  }

  static String decrypt(String encryptedTextWithIv) {
    final parts = encryptedTextWithIv.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid encrypted data format');
    }

    final encryptedData = base64Decode(parts[0]);
    final iv = base64Decode(parts[1]);

    final params = ParametersWithIV<KeyParameter>(KeyParameter(_key), iv);
    final blockCipher = CBCBlockCipher(AESEngine())
      ..init(false, params); // false means decrypt

    final decryptedData = _processCipher(encryptedData, blockCipher);
    return utf8.decode(_unpad(decryptedData));
  }

  static Uint8List _generateRandomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(length, (i) => rnd.nextInt(256)));
  }

  static Uint8List _processCipher(Uint8List inputData, BlockCipher cipher) {
    final output = Uint8List(inputData.length);

    for (var offset = 0;
        offset < inputData.length;
        offset += cipher.blockSize) {
      cipher.processBlock(inputData, offset, output, offset);
    }

    return output;
  }

  static Uint8List _pad(Uint8List src, int blockSize) {
    final padLength = blockSize - (src.length % blockSize);
    final padding = Uint8List(padLength)..fillRange(0, padLength, padLength);
    return Uint8List.fromList(src + padding);
  }

  static Uint8List _unpad(Uint8List src) {
    final padLength = src.last;
    return Uint8List.fromList(src.sublist(0, src.length - padLength));
  }
}
