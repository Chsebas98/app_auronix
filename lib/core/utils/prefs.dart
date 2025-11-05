import 'package:auronix_app/core/errors/errors.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class Prefs {
  final RxSharedPreferences _prefs;

  Prefs(this._prefs);

  // -- Métodos genéricos para obtener valores --
  T? getValue<T>(String key) {
    if (T == bool) return _prefs.getBool(key) as T?;
    if (T == int) return _prefs.getInt(key) as T?;
    if (T == double) return _prefs.getDouble(key) as T?;
    if (T == String) return _prefs.getString(key) as T?;
    if (T == List<String>) return _prefs.getStringList(key) as T?;
    return null;
  }

  Stream<T?> getValueStream<T>(String key) {
    if (T == bool) return _prefs.getBoolStream(key).map((v) => v as T?);
    if (T == int) return _prefs.getIntStream(key).map((v) => v as T?);
    if (T == double) return _prefs.getDoubleStream(key).map((v) => v as T?);
    if (T == String) return _prefs.getStringStream(key).map((v) => v as T?);
    if (T == List<String>) {
      return _prefs.getStringListStream(key).map((v) => v as T?);
    }
    return Stream.value(null);
  }

  // -- Métodos genéricos para establecer valores --
  Future<void> setValue<T>(String key, T value) async {
    if (T == bool) {
      await _prefs.setBool(key, value as bool);
    } else if (T == int) {
      await _prefs.setInt(key, value as int);
    } else if (T == double) {
      await _prefs.setDouble(key, value as double);
    } else if (T == String) {
      await _prefs.setString(key, value as String);
    } else if (T == List<String>) {
      await _prefs.setStringList(key, value as List<String>);
    } else {
      throw PrefsTypeException('Tipo no soportado para la clave "$key"');
    }
  }

  // -- Eliminar clave específica --
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // -- Limpiar todas las claves --
  Future<void> clearAll() {
    return _prefs.clear();
  }
}
