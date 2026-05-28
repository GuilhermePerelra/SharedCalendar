enum EventCategory {
  agendado('Agendado');

  final String displayName;

  const EventCategory(this.displayName);

  /// Converte uma string do banco para EventCategory
  static EventCategory? fromString(String? value) {
    if (value == null) return null;
    try {
      return EventCategory.values.firstWhere(
        (category) => category.name == value,
      );
    } catch (_) {
      return null;
    }
  }

  /// Retorna o valor para salvar no banco
  String toDbString() => name;
}
