import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_user.dart';

class UserRepository {
  const UserRepository(this._database);

  final Database _database;

  Future<Map<String, Object?>?> findByEmail(String email) async {
    final rows = await _database.query(
      'Usuarios',
      where: 'Email = ? COLLATE NOCASE AND IsDeleted = 0',
      whereArgs: [email.trim()],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateLastLogin(String id, DateTime date) async {
    await _database.update(
      'Usuarios',
      {'UltimoLogin': date.toUtc().toIso8601String()},
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  AppUser toAppUser(Map<String, Object?> row) => AppUser(
    id: row['Id']! as String,
    name: row['Nome']! as String,
    email: row['Email']! as String,
  );
}
