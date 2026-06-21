/// Contrato corporativo para persistencia local de datos y caché.
abstract class ILocalStorage {
  Future<void> write({required String key, required dynamic value});

  Future<dynamic> read({required String key});

  Future<void> delete({required String key});

  Future<void> clearAll();

  Future<bool> containsKey({required String key});
}
