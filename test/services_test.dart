import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ianika_app_dental_lab/data/dental_lab_database.dart';
import 'package:ianika_app_dental_lab/data/dentist_repository.dart';
import 'package:ianika_app_dental_lab/data/order_repository.dart';
import 'package:ianika_app_dental_lab/data/patient_repository.dart';
import 'package:ianika_app_dental_lab/data/user_repository.dart';
import 'package:ianika_app_dental_lab/models/dentist.dart';
import 'package:ianika_app_dental_lab/models/lab_order.dart';
import 'package:ianika_app_dental_lab/models/patient.dart';
import 'package:ianika_app_dental_lab/services/auth_service.dart';
import 'package:ianika_app_dental_lab/services/dentist_service.dart';
import 'package:ianika_app_dental_lab/services/file_logger.dart';
import 'package:ianika_app_dental_lab/services/order_service.dart';
import 'package:ianika_app_dental_lab/services/patient_service.dart';
import 'package:ianika_app_dental_lab/services/service_exception.dart';

void main() {
  late Directory directory;
  late DentalLabDatabase database;
  late FileLogger logger;
  late DentistService dentistService;
  late PatientService patientService;
  late OrderService orderService;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('dentallab_test_');
    database = await DentalLabDatabase.open(
      path: path.join(directory.path, 'test.db'),
    );
    logger = FileLogger(directory.path);
    final dentistRepository = DentistRepository(database.database);
    dentistService = DentistService(dentistRepository, logger);
    patientService = PatientService(
      PatientRepository(database.database),
      logger,
    );
    orderService = OrderService(OrderRepository(database.database), logger);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('autentica administrador seed e recusa senha incorreta', () async {
    final service = AuthService(UserRepository(database.database), logger);
    expect(
      await service.login('admin@dentallab.local', 'senha-errada'),
      isNull,
    );

    final user = await service.login('ADMIN@DENTALLAB.LOCAL', 'Admin@123');
    expect(user?.name, 'Administrador');

    final row = (await database.database.query(
      'Usuarios',
      columns: ['UltimoLogin'],
      where: 'Id = ?',
      whereArgs: [user!.id],
    )).single;
    expect(row['UltimoLogin'], isA<String>());
  });

  test(
    'cadastro de pacientes valida CPF, pesquisa e preserva exclusão lógica',
    () async {
      final dentist = await _createDentist(dentistService);
      final input = PatientInput(
        name: 'Maria Oliveira',
        cpf: '123.456.789-09',
        phone: '(11) 99999-0000',
        birthDate: DateTime(1990, 4, 12),
        dentistId: dentist.id,
      );

      await patientService.create(input);
      expect(
        (await patientService.getAll(search: 'maria')).single.name,
        input.name,
      );
      expect((await patientService.getAll(search: '123456')).length, 1);
      await expectLater(
        patientService.create(
          PatientInput(
            name: 'Maria Duplicada',
            cpf: '12345678909',
            phone: '11999990000',
            birthDate: DateTime(1991, 5, 1),
            dentistId: dentist.id,
          ),
        ),
        throwsA(isA<ServiceException>()),
      );

      var saved = (await patientService.getAll()).single;
      await patientService.update(
        saved.id,
        PatientInput(
          name: 'Maria Oliveira Silva',
          cpf: saved.cpf,
          phone: saved.phone,
          birthDate: saved.birthDate,
          dentistId: dentist.id,
          notes: 'Alergia registrada',
        ),
      );
      saved = (await patientService.getAll()).single;
      expect(saved.name, 'Maria Oliveira Silva');
      expect(saved.notes, 'Alergia registrada');

      await orderService.create(
        LabOrderInput(
          number: 'PED-PACIENTE-1',
          patientId: saved.id,
          dentistId: dentist.id,
          prosthesisType: 'Coroa',
          expectedDate: DateTime.now().add(const Duration(days: 3)),
          value: 120,
        ),
      );
      await patientService.delete(saved);
      expect(await patientService.getAll(), isEmpty);
      expect(
        (await orderService.getAll()).single.patientName,
        'Paciente removido',
      );
      final stored = (await database.database.query(
        'Pacientes',
        where: 'Id = ?',
        whereArgs: [saved.id],
      )).single;
      expect(stored['IsDeleted'], 1);
    },
  );

  test(
    'pedido é gerado, editado, troca status e excluído logicamente',
    () async {
      final dentist = await _createDentist(dentistService);
      await patientService.create(
        PatientInput(
          name: 'Paciente de Pedido',
          cpf: '98765432100',
          phone: '11999990000',
          birthDate: DateTime(1988, 2, 1),
          dentistId: dentist.id,
        ),
      );
      final patient = (await patientService.getAll()).single;
      final number = await orderService.nextOrderNumber();
      expect(number, startsWith('PED-'));

      await orderService.create(
        LabOrderInput(
          number: number,
          patientId: patient.id,
          dentistId: dentist.id,
          prosthesisType: 'Coroa',
          expectedDate: DateTime.now().add(const Duration(days: 5)),
          value: 250.50,
        ),
      );

      var order = (await orderService.getAll()).single;
      expect(order.status, OrderStatus.received);
      expect(order.patientName, patient.name);

      await orderService.update(
        order.id,
        LabOrderInput(
          number: order.number,
          patientId: patient.id,
          dentistId: dentist.id,
          prosthesisType: 'Coroa de porcelana',
          expectedDate: DateTime.now().add(const Duration(days: 7)),
          value: 300,
          notes: 'Prioridade',
        ),
      );
      order = (await orderService.getAll()).single;
      expect(order.prosthesisType, 'Coroa de porcelana');
      expect(order.notes, 'Prioridade');

      await orderService.updateStatus(order, OrderStatus.finished);
      order = (await orderService.getAll()).single;
      expect(order.status, OrderStatus.finished);
      expect(order.deliveryDate, isNotNull);

      await orderService.delete(order);
      expect(await orderService.getAll(), isEmpty);
      final stored = (await database.database.query(
        'Pedidos',
        where: 'Id = ?',
        whereArgs: [order.id],
      )).single;
      expect(stored['IsDeleted'], 1);
    },
  );

  test('pedido exige data prevista posterior e número único', () async {
    final dentist = await _createDentist(dentistService);
    await patientService.create(
      PatientInput(
        name: 'Paciente para validação',
        cpf: '12312312312',
        phone: '11999990000',
        birthDate: DateTime(1990, 1, 1),
        dentistId: dentist.id,
      ),
    );
    final patient = (await patientService.getAll()).single;
    final invalid = LabOrderInput(
      number: 'PED-TESTE-1',
      patientId: patient.id,
      dentistId: dentist.id,
      prosthesisType: 'Ponte',
      expectedDate: DateTime.now().subtract(const Duration(days: 1)),
      value: 100,
    );
    await expectLater(
      orderService.create(invalid),
      throwsA(isA<ServiceException>()),
    );

    final valid = LabOrderInput(
      number: invalid.number,
      patientId: patient.id,
      dentistId: dentist.id,
      prosthesisType: invalid.prosthesisType,
      expectedDate: DateTime.now().add(const Duration(days: 2)),
      value: 100,
    );
    await orderService.create(valid);
    await expectLater(
      orderService.create(valid),
      throwsA(isA<ServiceException>()),
    );
  });

  test('atualiza schema antigo sem apagar usuários ou dentistas', () async {
    final legacyDirectory = await Directory.systemTemp.createTemp(
      'dentallab_legacy_',
    );
    final legacyPath = path.join(legacyDirectory.path, 'legacy.db');
    final legacyDatabase = await databaseFactoryFfi.openDatabase(legacyPath);
    await legacyDatabase.execute('''
      CREATE TABLE Usuarios (
        Id TEXT PRIMARY KEY, CreatedAt TEXT NOT NULL, UpdatedAt TEXT,
        IsDeleted INTEGER NOT NULL DEFAULT 0, Nome TEXT NOT NULL,
        Email TEXT NOT NULL UNIQUE, SenhaHash TEXT NOT NULL,
        Ativo INTEGER NOT NULL DEFAULT 1, RecuperacaoToken TEXT,
        RecuperacaoTokenExpiracao TEXT, UltimoLogin TEXT
      )
    ''');
    await legacyDatabase.execute('''
      CREATE TABLE Dentistas (
        Id TEXT PRIMARY KEY, CreatedAt TEXT NOT NULL, UpdatedAt TEXT,
        IsDeleted INTEGER NOT NULL DEFAULT 0, Nome TEXT NOT NULL,
        CRO TEXT NOT NULL UNIQUE, Telefone TEXT NOT NULL, Email TEXT NOT NULL,
        Endereco TEXT NOT NULL, Observacoes TEXT
      )
    ''');
    await legacyDatabase.insert('Usuarios', {
      'Id': 'existing-user',
      'CreatedAt': '2024-01-01T00:00:00.000Z',
      'Nome': 'Usuário existente',
      'Email': 'existing@example.com',
      'SenhaHash': 'preserved-hash',
      'Ativo': 1,
    });
    await legacyDatabase.insert('Dentistas', {
      'Id': 'existing-dentist',
      'CreatedAt': '2024-01-01T00:00:00.000Z',
      'Nome': 'Dentista existente',
      'CRO': '111',
      'Telefone': '11999990000',
      'Email': 'dentist@example.com',
      'Endereco': 'Rua A',
    });
    await legacyDatabase.close();

    final upgraded = await DentalLabDatabase.open(path: legacyPath);
    expect(
      (await upgraded.database.query('Usuarios')).single['Nome'],
      'Usuário existente',
    );
    expect(
      (await upgraded.database.query('Dentistas')).single['Nome'],
      'Dentista existente',
    );
    expect(await upgraded.database.query('Pacientes'), isEmpty);
    expect(await upgraded.database.query('Pedidos'), isEmpty);
    await upgraded.close();
    await legacyDirectory.delete(recursive: true);
  });
}

Future<Dentist> _createDentist(DentistService service) async {
  await service.create(
    const DentistInput(
      name: 'Dra. Ana',
      cro: '12345',
      phone: '11999990000',
      email: 'ana@example.com',
      address: 'Rua Central, 10',
    ),
  );
  return (await service.getAll()).single;
}
