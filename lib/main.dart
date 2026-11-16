import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/dental_lab_database.dart';
import 'data/dentist_repository.dart';
import 'data/order_repository.dart';
import 'data/patient_repository.dart';
import 'data/user_repository.dart';
import 'services/auth_service.dart';
import 'services/dentist_service.dart';
import 'services/file_logger.dart';
import 'services/order_service.dart';
import 'services/patient_service.dart';
import 'ui/dental_lab_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final databasePath = Platform.environment['DENTALLAB_DB_PATH'];
  final database = await DentalLabDatabase.open(path: databasePath);
  final logger = FileLogger(database.directoryPath);
  final dentistRepository = DentistRepository(database.database);
  final patientRepository = PatientRepository(database.database);

  runApp(
    DentalLabApp(
      authService: AuthService(UserRepository(database.database), logger),
      dentistService: DentistService(dentistRepository, logger),
      patientService: PatientService(patientRepository, logger),
      orderService: OrderService(OrderRepository(database.database), logger),
    ),
  );
}
