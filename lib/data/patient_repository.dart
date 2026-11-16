import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/dentist.dart';
import '../models/patient.dart';
import 'id_generator.dart';

class PatientRepository {
  const PatientRepository(this._database);

  final Database _database;

  Future<List<Patient>> getAll({String search = ''}) async {
    final rows = await _database.rawQuery('''
      SELECT p.*, d.Nome AS DentistaNome
      FROM Pacientes p
      JOIN Dentistas d ON d.Id = p.DentistaResponsavelId
      WHERE p.IsDeleted = 0 AND d.IsDeleted = 0
      ORDER BY p.Nome COLLATE NOCASE
    ''');
    final term = search.trim().toLowerCase();
    final normalizedCpf = term.replaceAll(RegExp(r'\D'), '');
    return rows
        .map(Patient.fromMap)
        .where(
          (patient) =>
              term.isEmpty ||
              patient.name.toLowerCase().contains(term) ||
              (normalizedCpf.isNotEmpty &&
                  patient.cpf
                      .replaceAll(RegExp(r'\D'), '')
                      .contains(normalizedCpf)),
        )
        .toList();
  }

  Future<Patient?> getById(String id) async {
    final rows = await _database.rawQuery(
      '''
      SELECT p.*, d.Nome AS DentistaNome
      FROM Pacientes p
      JOIN Dentistas d ON d.Id = p.DentistaResponsavelId
      WHERE p.Id = ? AND p.IsDeleted = 0 AND d.IsDeleted = 0
      LIMIT 1
      ''',
      [id],
    );
    return rows.isEmpty ? null : Patient.fromMap(rows.first);
  }

  Future<bool> cpfExists(String cpf, {String? excludingId}) async {
    final rows = await _database.query(
      'Pacientes',
      columns: ['Id', 'CPF'],
      where: excludingId == null ? null : 'Id != ?',
      whereArgs: excludingId == null ? null : [excludingId],
    );
    final normalizedCpf = cpf.replaceAll(RegExp(r'\D'), '');
    return rows.any(
      (row) =>
          (row['CPF']! as String).replaceAll(RegExp(r'\D'), '') ==
          normalizedCpf,
    );
  }

  Future<List<Dentist>> getDentists() async {
    final rows = await _database.query(
      'Dentistas',
      where: 'IsDeleted = 0',
      orderBy: 'Nome COLLATE NOCASE',
    );
    return rows.map(Dentist.fromMap).toList();
  }

  Future<bool> dentistExists(String id) async {
    final rows = await _database.query(
      'Dentistas',
      columns: ['Id'],
      where: 'Id = ? AND IsDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> create(PatientInput input) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insert('Pacientes', {
      'Id': newId(),
      'CreatedAt': now,
      'UpdatedAt': null,
      'IsDeleted': 0,
      ..._toColumns(input),
    });
  }

  Future<int> update(String id, PatientInput input) => _database.update(
    'Pacientes',
    {
      ..._toColumns(input),
      'UpdatedAt': DateTime.now().toUtc().toIso8601String(),
    },
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Future<int> softDelete(String id) => _database.update(
    'Pacientes',
    {'IsDeleted': 1, 'UpdatedAt': DateTime.now().toUtc().toIso8601String()},
    where: 'Id = ? AND IsDeleted = 0',
    whereArgs: [id],
  );

  Map<String, Object?> _toColumns(PatientInput input) => {
    'Nome': input.name.trim(),
    'CPF': input.cpf.replaceAll(RegExp(r'\D'), ''),
    'Telefone': input.phone.trim(),
    'DataNascimento': input.birthDate.toUtc().toIso8601String(),
    'DentistaResponsavelId': input.dentistId,
    'Observacoes': _nullableText(input.notes),
  };
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
