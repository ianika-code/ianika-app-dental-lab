import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/dentist.dart';
import 'id_generator.dart';

class DentistRepository {
  const DentistRepository(this._database);

  final Database _database;

  Future<List<Dentist>> getAll({String search = ''}) async {
    final rows = await _database.query(
      'Dentistas',
      where: 'IsDeleted = 0',
      orderBy: 'Nome COLLATE NOCASE',
    );
    final term = search.trim().toLowerCase();
    return rows
        .map(Dentist.fromMap)
        .where(
          (dentist) =>
              term.isEmpty ||
              dentist.name.toLowerCase().contains(term) ||
              dentist.cro.toLowerCase().contains(term),
        )
        .toList();
  }

  Future<Dentist?> getById(String id) async {
    final rows = await _database.query(
      'Dentistas',
      where: 'Id = ? AND IsDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Dentist.fromMap(rows.first);
  }

  Future<bool> croExists(String cro, {String? excludingId}) async {
    final rows = await _database.query(
      'Dentistas',
      columns: ['Id'],
      where:
          'CRO = ? COLLATE NOCASE${excludingId == null ? '' : ' AND Id != ?'}',
      whereArgs: excludingId == null ? [cro] : [cro, excludingId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> _hasLinkedRecords(
    String table,
    String foreignKey,
    String id,
  ) async {
    final tables = await _database.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );
    if (tables.isEmpty) return false;
    final rows = await _database.rawQuery(
      'SELECT 1 FROM "$table" WHERE "$foreignKey" = ? AND IsDeleted = 0 LIMIT 1',
      [id],
    );
    return rows.isNotEmpty;
  }

  Future<bool> hasLinkedPatients(String id) =>
      _hasLinkedRecords('Pacientes', 'DentistaResponsavelId', id);

  Future<bool> hasLinkedOrders(String id) =>
      _hasLinkedRecords('Pedidos', 'DentistaId', id);

  Future<void> create(DentistInput input) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insert('Dentistas', {
      'Id': newId(),
      'CreatedAt': now,
      'UpdatedAt': null,
      'IsDeleted': 0,
      ..._toColumns(input),
    });
  }

  Future<int> update(String id, DentistInput input) => _database.update(
    'Dentistas',
    {
      ..._toColumns(input),
      'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
    },
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Future<int> softDelete(String id) => _database.update(
    'Dentistas',
    {'IsDeleted': 1, 'UpdatedAt': DateTime.now().toUtc().toIso8601String()},
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Map<String, Object?> _toColumns(DentistInput input) => {
    'Nome': input.name.trim(),
    'CRO': input.cro.trim(),
    'Telefone': input.phone.trim(),
    'Email': input.email.trim(),
    'Endereco': input.address.trim(),
    'Observacoes': _nullableText(input.notes),
  };
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
