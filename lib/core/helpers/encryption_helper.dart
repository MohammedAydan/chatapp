import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static String _formatKey(String encryptionKey) {
    if (encryptionKey.length < 32) {
      encryptionKey = encryptionKey.padRight(32, 'e');
    } else if (encryptionKey.length > 32) {
      encryptionKey = encryptionKey.substring(0, 32);
    }
    return encryptionKey;
  }

  static String encryptText(String text, String encryptionKey) {
    final key = Key.fromUtf8(_formatKey(encryptionKey));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decryptText(String encryptedText, String encryptionKey) {
    final key = Key.fromUtf8(_formatKey(encryptionKey));
    final parts = encryptedText.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encryptedData = Encrypted.fromBase64(parts[1]);
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt(encryptedData, iv: iv);
  }

  static String encryptObject(Object data, String encryptionKey) {
    final jsonText = jsonEncode(data);
    return encryptText(jsonText, encryptionKey);
  }

  static Map<String, dynamic> decryptToMap(String encryptedText, String encryptionKey) {
    final decryptedText = decryptText(encryptedText, encryptionKey);
    return jsonDecode(decryptedText);
  }
}