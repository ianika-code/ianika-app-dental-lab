import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as path_utils;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/dental_lab_database.dart';
import 'data/agenda_repository.dart';
import 'data/dentist_repository.dart';
import 'data/inventory_repository.dart';
import 'data/order_repository.dart';
import 'data/patient_repository.dart';
import 'data/user_repository.dart';
import 'services/auth_service.dart';
import 'services/agenda_service.dart';
import 'services/dentist_service.dart';
import 'services/file_logger.dart';
import 'services/inventory_service.dart';
import 'services/order_service.dart';
import 'services/patient_service.dart';
import 'ui/dental_lab_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final databasePath = Platform.environment['DENTALLAB_DB_PATH'];
  final logDirectory = path_utils.dirname(
    DentalLabDatabase.resolveDatabasePath(databasePath),
  );
  final logger = FileLogger(logDirectory);
  late final DentalLabDatabase database;
  try {
    database = await DentalLabDatabase.open(path: databasePath);
  } catch (error, stackTrace) {
    logger.error('Falha ao inicializar o banco de dados', error, stackTrace);
    rethrow;
  }
  final dentistRepository = DentistRepository(database.database);
  final patientRepository = PatientRepository(database.database);
  final orderRepository = OrderRepository(database.database);

  runApp(
    DentalLabApp(
      authService: AuthService(UserRepository(database.database), logger),
      dentistService: DentistService(dentistRepository, logger),
      patientService: PatientService(patientRepository, logger),
      orderService: OrderService(orderRepository, logger),
      inventoryService: InventoryService(
        InventoryRepository(database.database),
        logger,
      ),
      agendaService: AgendaService(
        AgendaRepository(database.database),
        orderRepository,
        dentistRepository,
        logger,
      ),
    ),
  );
}
