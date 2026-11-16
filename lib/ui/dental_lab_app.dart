import 'package:material_ui/material_ui.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/dentist_service.dart';
import '../services/order_service.dart';
import '../services/patient_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class DentalLabApp extends StatefulWidget {
  const DentalLabApp({
    required this.authService,
    required this.dentistService,
    required this.patientService,
    required this.orderService,
    super.key,
  });

  final AuthService authService;
  final DentistService dentistService;
  final PatientService patientService;
  final OrderService orderService;

  @override
  State<DentalLabApp> createState() => _DentalLabAppState();
}

class _DentalLabAppState extends State<DentalLabApp> {
  AppUser? _user;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DentalLab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF176B72),
        surface: const Color(0xFFF7F9FA),
      ),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: _user == null
        ? LoginScreen(
            authService: widget.authService,
            onLogin: (user) => setState(() => _user = user),
          )
        : MainScreen(
            user: _user!,
            dentistService: widget.dentistService,
            patientService: widget.patientService,
            orderService: widget.orderService,
            onLogout: () => setState(() => _user = null),
          ),
  );
}
