import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/inventory_item.dart';
import '../models/stock_movement.dart';
import 'id_generator.dart';

class InventoryRepository {
  const InventoryRepository(this._database);

  final Database _database;

  Future<List<InventoryItem>> getAll({
    String search = '',
    StockCategory? category,
    bool lowOnly = false,
  }) async {
    final conditions = <String>['IsDeleted = 0'];
    final arguments = <Object?>[];
    if (category != null) {
      conditions.add('Categoria = ?');
      arguments.add(category.index);
    }
    if (lowOnly) conditions.add('QuantidadeAtual <= QuantidadeMinima');

    final rows = await _database.query(
      'EstoqueItems',
      where: conditions.join(' AND '),
      whereArgs: arguments,
      orderBy: 'Nome COLLATE NOCASE',
    );
    final term = search.trim().toLowerCase();
    return rows
        .map(InventoryItem.fromMap)
        .where(
          (item) =>
              term.isEmpty ||
              item.name.toLowerCase().contains(term) ||
              (item.supplier?.toLowerCase().contains(term) ?? false),
        )
        .toList();
  }

  Future<InventoryItem?> getById(String id) async {
    final rows = await _database.query(
      'EstoqueItems',
      where: 'Id = ? AND IsDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : InventoryItem.fromMap(rows.first);
  }

  Future<bool> nameExists(String name, {String? excludingId}) async {
    final rows = await _database.query(
      'EstoqueItems',
      columns: ['Id'],
      where:
          'Nome = ? COLLATE NOCASE AND IsDeleted = 0${excludingId == null ? '' : ' AND Id != ?'}',
      whereArgs: excludingId == null ? [name.trim()] : [name.trim(), excludingId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<InventoryItem>> getLowStock() =>
      getAll(lowOnly: true);

  Future<void> create(InventoryItemInput input) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insert('EstoqueItems', {
      'Id': newId(),
      'CreatedAt': now,
      'UpdatedAt': null,
      'IsDeleted': 0,
      'Nome': input.name.trim(),
      'Categoria': input.category.index,
      'Descricao': _nullableText(input.description),
      'QuantidadeAtual': 0,
      'QuantidadeMinima': input.minimumQuantity,
      'UnidadeMedida': input.unit.trim(),
      'ValorUnitario': input.unitPrice,
      'Fornecedor': _nullableText(input.supplier),
      'DataUltimaEntrada': null,
    });
  }

  Future<int> update(String id, InventoryItemInput input) => _database.update(
        'EstoqueItems',
        {
          'Nome': input.name.trim(),
          'Categoria': input.category.index,
          'Descricao': _nullableText(input.description),
          'QuantidadeMinima': input.minimumQuantity,
          'UnidadeMedida': input.unit.trim(),
          'ValorUnitario': input.unitPrice,
          'Fornecedor': _nullableText(input.supplier),
          'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'Id = ? AND IsDeleted = 0',
        whereArgs: [id],
      );

  Future<InventoryItem> recordMovement(StockMovementInput input) async {
    return _database.transaction((transaction) async {
      final rows = await transaction.query(
        'EstoqueItems',
        where: 'Id = ? AND IsDeleted = 0',
        whereArgs: [input.itemId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('Item de estoque não encontrado.');

      final item = InventoryItem.fromMap(rows.first);
      if (input.quantity <= 0) {
        throw StateError('A quantidade deve ser maior que zero.');
      }
      if (input.type == StockMovementType.exit &&
          input.quantity > item.currentQuantity) {
        throw StateError(
          'Quantidade insuficiente. Disponível: ${item.currentQuantity} ${item.unit}.',
        );
      }
      final updatedQuantity = input.type == StockMovementType.entry
          ? item.currentQuantity + input.quantity
          : item.currentQuantity - input.quantity;
      if (updatedQuantity > 2147483647) {
        throw StateError('A quantidade excede o limite suportado.');
      }

      final now = DateTime.now().toUtc();
      await transaction.update(
        'EstoqueItems',
        {
          'QuantidadeAtual': updatedQuantity,
          'UpdatedAt': now.toIso8601String(),
          if (input.type == StockMovementType.entry)
            'DataUltimaEntrada': now.toIso8601String(),
        },
        where: 'Id = ? AND IsDeleted = 0',
        whereArgs: [input.itemId],
      );
      await transaction.insert('MovimentacoesEstoque', {
        'Id': newId(),
        'CreatedAt': now.toIso8601String(),
        'UpdatedAt': null,
        'IsDeleted': 0,
        'EstoqueItemId': input.itemId,
        'Tipo': input.type.index,
        'Quantidade': input.quantity,
        'DataMovimentacao': now.toIso8601String(),
        'Motivo': input.reason.trim(),
        'Observacoes': _nullableText(input.notes),
      });

      final updatedRows = await transaction.query(
        'EstoqueItems',
        where: 'Id = ?',
        whereArgs: [input.itemId],
        limit: 1,
      );
      return InventoryItem.fromMap(updatedRows.single);
    });
  }

  Future<int> softDelete(String id) => _database.update(
        'EstoqueItems',
        {
          'IsDeleted': 1,
          'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'Id = ? AND IsDeleted = 0',
        whereArgs: [id],
      );

  Future<List<StockMovement>> getHistory(String itemId) async {
    final rows = await _database.rawQuery(
      '''
      SELECT m.*, i.Nome AS EstoqueItemNome
      FROM MovimentacoesEstoque m
      LEFT JOIN EstoqueItems i ON i.Id = m.EstoqueItemId
      WHERE m.EstoqueItemId = ? AND m.IsDeleted = 0
      ORDER BY m.DataMovimentacao DESC
      ''',
      [itemId],
    );
    return rows.map(StockMovement.fromMap).toList();
  }
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
