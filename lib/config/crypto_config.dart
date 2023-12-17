
import 'package:encrypt/encrypt.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class CryptoConfig {
  static final _key = Key.fromUtf8('Lam sao ha......................');
  static final _iv = IV.fromLength(16);
  static String encrypt(String jsonEncode) {
    return _encrypter.encrypt(jsonEncode, iv: _iv).base64;
  }

  static String decrypt(String jsonDecode) {
    final data = _encrypter.decrypt64(jsonDecode, iv: _iv);
    log('>>>>>>>>>>>>$data');
    return data;
  }

  static final _encrypter = Encrypter(AES(_key));
}
