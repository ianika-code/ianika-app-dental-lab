import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/dentist.dart';
import '../models/lab_order.dart';
import '../models/patient.dart';
import 'id_generator.dart';

class OrderRepository {
  const OrderRepository(this._database);

  final Database _database;

  Future<List<LabOrder>> getAll({String search = ''}) async {
    final rows = await _database.rawQuery('''
      SELECT o.*, p.Nome AS PacienteNome, d.Nome AS DentistaNome
      FROM Pedidos o
      LEFT JOIN Pacientes p ON p.Id = o.PacienteId AND p.IsDeleted = 0
      LEFT JOIN Dentistas d ON d.Id = o.DentistaId AND d.IsDeleted = 0
      WHERE o.IsDeleted = 0
      ORDER BY o.DataPedido DESC, o.NumeroPedido DESC
    ''');
    final term = search.trim().toLowerCase();
    return rows
        .map(LabOrder.fromMap)
        .where(
          (order) =>
              term.isEmpty ||
              order.number.toLowerCase().contains(term) ||
              order.patientName.toLowerCase().contains(term) ||
              order.dentistName.toLowerCase().contains(term),
        )
        .toList();
  }

  Future<LabOrder?> getById(String id) async {
    final rows = await _database.rawQuery(
      '''
      SELECT o.*, p.Nome AS PacienteNome, d.Nome AS DentistaNome
      FROM Pedidos o
      LEFT JOIN Pacientes p ON p.Id = o.PacienteId
      LEFT JOIN Dentistas d ON d.Id = o.DentistaId
      WHERE o.Id = ? AND o.IsDeleted = 0
      LIMIT 1
      ''',
      [id],
    );
    return rows.isEmpty ? null : LabOrder.fromMap(rows.first);
  }

  Future<List<Patient>> getPatients() async {
    final rows = await _database.rawQuery('''
      SELECT p.*, d.Nome AS DentistaNome
      FROM Pacientes p
      JOIN Dentistas d ON d.Id = p.DentistaResponsavelId
      WHERE p.IsDeleted = 0 AND d.IsDeleted = 0
      ORDER BY p.Nome COLLATE NOCASE
    ''');
    return rows.map(Patient.fromMap).toList();
  }

  Future<List<Dentist>> getDentists() async {
    final rows = await _database.query(
      'Dentistas',
      where: 'IsDeleted = 0',
      orderBy: 'Nome COLLATE NOCASE',
    );
    return rows.map(Dentist.fromMap).toList();
  }

  Future<bool> referencesExist(String patientId, String dentistId) async {
    final rows = await _database.rawQuery(
      '''
      SELECT 1
      FROM Pacientes p JOIN Dentistas d ON d.Id = ?
      WHERE p.Id = ? AND p.IsDeleted = 0 AND d.IsDeleted = 0
      LIMIT 1
      ''',
      [dentistId, patientId],
    );
    return rows.isNotEmpty;
  }

  Future<bool> numberExists(String number, {String? excludingId}) async {
    final rows = await _database.query(
      'Pedidos',
      columns: ['Id'],
      where:
          'NumeroPedido = ? COLLATE NOCASE${excludingId == null ? '' : ' AND Id != ?'}',
      whereArgs: excludingId == null ? [number] : [number, excludingId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<String?> latestNumberForPrefix(String prefix) async {
    final rows = await _database.query(
      'Pedidos',
      columns: ['NumeroPedido'],
      where: 'NumeroPedido LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'NumeroPedido DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['NumeroPedido']! as String;
  }

  Future<void> create(LabOrderInput input) async {
    final now = DateTime.now().toUtc();
    await _database.insert('Pedidos', {
      'Id': newId(),
      'CreatedAt': now.toIso8601String(),
      'UpdatedAt': null,
      'IsDeleted': 0,
      ..._toColumns(input),
      'DataPedido': now.toIso8601String(),
      'DataEntrega': null,
      'Status': OrderStatus.received.index,
    });
  }

  Future<int> update(String id, LabOrderInput input) => _database.update(
    'Pedidos',
    {
      ..._toColumns(input),
      'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
    },
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Future<int> updateStatus(String id, OrderStatus status) => _database.update(
    'Pedidos',
    {
      'Status': status.index,
      if (status == OrderStatus.finished)
        'DataEntrega': DateTime.now().toUtc().toIso8601String(),
      'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
    },
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Future<int> softDelete(String id) => _database.update(
    'Pedidos',
    {'IsDeleted': 1, 'UpdatedAt': DateTime.now().toUtc().toIso8601String()},
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Map<String, Object?> _toColumns(LabOrderInput input) => {
    'NumeroPedido': input.number.trim(),
    'PacienteId': input.patientId,
    'DentistaId': input.dentistId,
    'TipoProtese': input.prosthesisType.trim(),
    'DataPrevista': input.expectedDate.toUtc().toIso8601String(),
    'Valor': input.value,
    'Observacoes': _nullableText(input.notes),
  };
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
