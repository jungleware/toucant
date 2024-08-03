class Store {}

enum StoreKey<T> {
  themeMode<String>(100),
  ;

  const StoreKey(this.id);

  final int id;
}

class StoreKeyNotFoundException implements Exception {
  final StoreKey key;

  const StoreKeyNotFoundException(this.key);

  @override
  String toString() => "Key ${key.name} not found in local store";
}
