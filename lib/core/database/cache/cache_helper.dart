import 'package:get_storage/get_storage.dart';

class CacheHelper {
  final GetStorage _getStorage;

  CacheHelper(this._getStorage);

  Future<void> save(String key, dynamic value) async {
    await _getStorage.write(key, value);
  }

  Future<void> delete(String key) async {
    await _getStorage.remove(key);
  }

  Future<void> put(String key, dynamic value) async {
    await _getStorage.write(key, value);
  }

  Future<dynamic> read<T>(String key) async {
    return _getStorage.read<T>(key);
  }

  T? readData<T>(String key) {
    return _getStorage.read<T>(key);
  }

  Future<void> clear() async {
    await _getStorage.erase();
  }

  Future<bool> containsKey(String key) async {
    return _getStorage.hasData(key);
  }

  Future<void> deleteAll(Iterable<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
