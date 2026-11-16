enum StockMovementType {
  entry('Entrada'),
  exit('Saída');

  const StockMovementType(this.label);

  final String label;

  static StockMovementType fromDatabase(Object? value) {
    final index = value is int ? value : int.tryParse('$value');
    if (index == null || index < 0 || index >= values.length) {
      throw FormatException('Tipo de movimentação inválido no banco: $value');
    }
    return values[index];
  }
}

class StockMovement {
  const StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.date,
    required this.reason,
    this.notes,
  });

  final String id;
  final String itemId;
  final String itemName;
  final StockMovementType type;
  final int quantity;
  final DateTime date;
  final String reason;
  final String? notes;

  factory StockMovement.fromMap(Map<String, Object?> map) => StockMovement(
        id: map['Id']! as String,
        itemId: map['EstoqueItemId']! as String,
        itemName: map['EstoqueItemNome'] as String? ?? 'Item removido',
        type: StockMovementType.fromDatabase(map['Tipo']),
        quantity: (map['Quantidade']! as num).toInt(),
        date: DateTime.parse(map['DataMovimentacao']! as String),
        reason: map['Motivo']! as String,
        notes: map['Observacoes'] as String?,
      );
}

class StockMovementInput {
  const StockMovementInput({
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  final String itemId;
  final StockMovementType type;
  final int quantity;
  final String reason;
  final String? notes;
}
