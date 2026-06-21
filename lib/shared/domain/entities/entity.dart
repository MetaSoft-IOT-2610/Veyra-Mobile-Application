/// Todo modelo de dominio que tenga una identidad única debe heredar de esta clase.
abstract class Entity<T> {
  final T id;

  const Entity({required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entity<T> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
