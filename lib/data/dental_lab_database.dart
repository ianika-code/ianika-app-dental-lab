import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:path/path.dart' as path_utils;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'id_generator.dart';

class DentalLabDatabase {
  DentalLabDatabase._(this.database, this.directoryPath);

  final Database database;
  final String directoryPath;

  static Future<DentalLabDatabase> open({String? path}) async {
    final databasePath = path == null || path.trim().isEmpty
        ? path_utils.join(_defaultDirectory(), 'dental-lab-db.db')
        : File(path).absolute.path;
    final directoryPath = path_utils.dirname(databasePath);
    await Directory(directoryPath).create(recursive: true);

    final database = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await _ensureSchema(db);
          await _seedAdministrator(db);
        },
        onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await _ensureSchema(db);
          await _seedAdministrator(db);
        },
      ),
    );
    return DentalLabDatabase._(database, directoryPath);
  }

  Future<void> close() => database.close();

  static String _defaultDirectory() {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return path_utils.join(localAppData, 'DentalLab');
    }
    return Directory.current.path;
  }

  static Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Usuarios (
        Id TEXT NOT NULL PRIMARY KEY,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT,
        IsDeleted INTEGER NOT NULL DEFAULT 0,
        Nome TEXT NOT NULL CHECK(length(Nome) <= 150),
        Email TEXT NOT NULL COLLATE NOCASE UNIQUE CHECK(length(Email) <= 150),
        SenhaHash TEXT NOT NULL,
        Ativo INTEGER NOT NULL DEFAULT 1,
        RecuperacaoToken TEXT,
        RecuperacaoTokenExpiracao TEXT,
        UltimoLogin TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Dentistas (
        Id TEXT NOT NULL PRIMARY KEY,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT,
        IsDeleted INTEGER NOT NULL DEFAULT 0,
        Nome TEXT NOT NULL CHECK(length(Nome) <= 150),
        CRO TEXT NOT NULL COLLATE NOCASE UNIQUE CHECK(length(CRO) <= 20),
        Telefone TEXT NOT NULL CHECK(length(Telefone) <= 20),
        Email TEXT NOT NULL CHECK(length(Email) <= 150),
        Endereco TEXT NOT NULL CHECK(length(Endereco) <= 300),
        Observacoes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Pacientes (
        Id TEXT NOT NULL PRIMARY KEY,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT,
        IsDeleted INTEGER NOT NULL DEFAULT 0,
        Nome TEXT NOT NULL CHECK(length(Nome) <= 150),
        CPF TEXT NOT NULL CHECK(length(CPF) <= 14),
        Telefone TEXT NOT NULL CHECK(length(Telefone) <= 20),
        DataNascimento TEXT NOT NULL,
        DentistaResponsavelId TEXT NOT NULL,
        Observacoes TEXT,
        FOREIGN KEY(DentistaResponsavelId) REFERENCES Dentistas(Id) ON DELETE RESTRICT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Pedidos (
        Id TEXT NOT NULL PRIMARY KEY,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT,
        IsDeleted INTEGER NOT NULL DEFAULT 0,
        NumeroPedido TEXT NOT NULL CHECK(length(NumeroPedido) <= 50),
        PacienteId TEXT NOT NULL,
        DentistaId TEXT NOT NULL,
        TipoProtese TEXT NOT NULL CHECK(length(TipoProtese) <= 100),
        DataPedido TEXT NOT NULL,
        DataPrevista TEXT NOT NULL,
        DataEntrega TEXT,
        Valor REAL NOT NULL,
        Status INTEGER NOT NULL DEFAULT 0,
        Observacoes TEXT,
        FOREIGN KEY(PacienteId) REFERENCES Pacientes(Id) ON DELETE RESTRICT,
        FOREIGN KEY(DentistaId) REFERENCES Dentistas(Id) ON DELETE RESTRICT
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS IX_Dentistas_CRO ON Dentistas(CRO)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS IX_Pacientes_CPF ON Pacientes(CPF)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS IX_Pedidos_NumeroPedido ON Pedidos(NumeroPedido)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS IX_Pacientes_IsDeleted_Nome ON Pacientes(IsDeleted, Nome)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS IX_Pedidos_IsDeleted_DataPedido ON Pedidos(IsDeleted, DataPedido)',
    );
  }

  static Future<void> _seedAdministrator(Database db) async {
    final rows = await db.rawQuery('SELECT 1 FROM Usuarios LIMIT 1');
    if (rows.isNotEmpty) return;

    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('Usuarios', {
      'Id': newId(),
      'CreatedAt': now,
      'UpdatedAt': null,
      'IsDeleted': 0,
      'Nome': 'Administrador',
      'Email': 'admin@dentallab.local',
      'SenhaHash': BCrypt.hashpw('Admin@123', BCrypt.gensalt()),
      'Ativo': 1,
      'RecuperacaoToken': null,
      'RecuperacaoTokenExpiracao': null,
      'UltimoLogin': null,
    });
  }
}
