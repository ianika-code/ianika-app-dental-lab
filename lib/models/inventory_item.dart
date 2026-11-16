enum StockCategory {
  resins('Resinas'),
  plasters('Gessos'),
  artificialTeeth('Dentes artificiais'),
  miscellaneous('Materiais diversos');

  const StockCategory(this.label);

  final String label;

  static StockCategory fromDatabase(Object? value) {
    final index = value is int ? value : int.tryParse('$value');
    if (index == null || index < 0 || index >= values.length) {
      throw FormatException('Categoria de estoque inválida no banco: $value');
    }
    return values[index];
  }
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentQuantity,
    required this.minimumQuantity,
    required this.unit,
    required this.unitPrice,
    this.description,
    this.supplier,
    this.lastEntry,
  });

  final String id;
  final String name;
  final StockCategory category;
  final int currentQuantity;
  final int minimumQuantity;
  final String unit;
  final double unitPrice;
  final String? description;
  final String? supplier;
  final DateTime? lastEntry;

  bool get isLow => currentQuantity <= minimumQuantity;

  factory InventoryItem.fromMap(Map<String, Object?> map) => InventoryItem(
        id: map['Id']! as String,
        name: map['Nome']! as String,
        category: StockCategory.fromDatabase(map['Categoria']),
        currentQuantity: (map['QuantidadeAtual']! as num).toInt(),
        minimumQuantity: (map['QuantidadeMinima']! as num).toInt(),
        unit: map['UnidadeMedida']! as String,
        unitPrice: (map['ValorUnitario']! as num).toDouble(),
        description: map['Descricao'] as String?,
        supplier: map['Fornecedor'] as String?,
        lastEntry: map['DataUltimaEntrada'] == null
            ? null
            : DateTime.parse(map['DataUltimaEntrada']! as String),
      );
}

class InventoryItemInput {
  const InventoryItemInput({
    required this.name,
    required this.category,
    required this.minimumQuantity,
    required this.unit,
    required this.unitPrice,
    this.description,
    this.supplier,
  });

  final String name;
  final StockCategory category;
  final int minimumQuantity;
  final String unit;
  final double unitPrice;
  final String? description;
  final String? supplier;
}
