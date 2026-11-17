import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/agenda_event.dart';
import 'id_generator.dart';

class AgendaRepository {
  const AgendaRepository(this._database);

  final Database _database;

  Future<List<AgendaEvent>> getAll() async {
    final rows = await _database.rawQuery('''
      SELECT e.*, o.NumeroPedido AS PedidoNumero, d.Nome AS DentistaNome
      FROM EventosAgenda e
      LEFT JOIN Pedidos o ON o.Id = e.PedidoId
      LEFT JOIN Dentistas d ON d.Id = e.DentistaId
      WHERE e.IsDeleted = 0
    ''');
    final events = rows.map(AgendaEvent.fromMap).toList()
      ..sort((first, second) => first.dateTime.compareTo(second.dateTime));
    return events;
  }

  Future<List<AgendaEvent>> getUpcoming({int days = 7}) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    final events = await getAll();
    return events
        .where(
          (event) =>
              !event.completed &&
              !event.dateTime.isBefore(now) &&
              !event.dateTime.isAfter(end),
        )
        .toList();
  }

  Future<bool> orderExists(String? id) async {
    if (id == null) return true;
    final rows = await _database.query(
      'Pedidos',
      columns: ['Id'],
      where: 'Id = ? AND IsDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> dentistExists(String? id) async {
    if (id == null) return true;
    final rows = await _database.query(
      'Dentistas',
      columns: ['Id'],
      where: 'Id = ? AND IsDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> create(AgendaEventInput input) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insert('EventosAgenda', {
      'Id': newId(),
      'CreatedAt': now,
      'UpdatedAt': null,
      'IsDeleted': 0,
      'Tipo': input.type.index,
      'Titulo': input.title.trim(),
      'Descricao': _nullableText(input.description),
      'DataHora': input.dateTime.toLocal().toIso8601String(),
      'PedidoId': input.orderId,
      'DentistaId': input.dentistId,
      'Concluido': 0,
    });
  }

  Future<int> update(String id, AgendaEventInput input) => _database.update(
        'EventosAgenda',
        {
          'Tipo': input.type.index,
          'Titulo': input.title.trim(),
          'Descricao': _nullableText(input.description),
          'DataHora': input.dateTime.toLocal().toIso8601String(),
          'PedidoId': input.orderId,
          'DentistaId': input.dentistId,
          'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'Id = ? AND IsDeleted = 0',
        whereArgs: [id],
      );

  Future<int> markCompleted(String id) => _database.update(
        'EventosAgenda',
        {
          'Concluido': 1,
          'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'Id = ? AND IsDeleted = 0 AND Concluido = 0',
        whereArgs: [id],
      );

  Future<int> softDelete(String id) => _database.update(
        'EventosAgenda',
        {
          'IsDeleted': 1,
          'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'Id = ? AND IsDeleted = 0',
        whereArgs: [id],
      );
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
