import 'package:material_ui/material_ui.dart';

import '../models/app_user.dart';
import '../services/dentist_service.dart';
import '../services/agenda_service.dart';
import '../services/inventory_service.dart';
import '../services/order_service.dart';
import '../services/patient_service.dart';
import 'dashboard_page.dart';
import 'agenda_page.dart';
import 'dentists_page.dart';
import 'inventory_page.dart';
import 'orders_page.dart';
import 'patients_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    required this.user,
    required this.dentistService,
    required this.patientService,
    required this.orderService,
    required this.inventoryService,
    required this.agendaService,
    required this.onLogout,
    super.key,
  });

  final AppUser user;
  final DentistService dentistService;
  final PatientService patientService;
  final OrderService orderService;
  final InventoryService inventoryService;
  final AgendaService agendaService;
  final VoidCallback onLogout;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  String get _title => switch (_selectedIndex) {
    0 => 'Visão geral',
    1 => 'Dentistas',
    2 => 'Pacientes',
    3 => 'Pedidos',
    4 => 'Estoque',
    _ => 'Agenda',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        NavigationRail(
          extended: true,
          minExtendedWidth: 230,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 28),
            child: Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'DentalLab',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Dentistas'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('Pacientes'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: Text('Pedidos'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: Text('Estoque'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: Text('Agenda'),
            ),
          ],
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                ),
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: SizedBox(
                  height: 72,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Text(
                          _title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        CircleAvatar(
                          radius: 16,
                          child: Text(
                            widget.user.name.isEmpty
                                ? 'U'
                                : widget.user.name
                                      .substring(0, 1)
                                      .toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(widget.user.name),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildPage()),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildPage() => switch (_selectedIndex) {
    0 => DashboardPage(
      dentistService: widget.dentistService,
      patientService: widget.patientService,
      orderService: widget.orderService,
      inventoryService: widget.inventoryService,
      agendaService: widget.agendaService,
      onNavigate: (index) => setState(() => _selectedIndex = index),
    ),
    1 => DentistsPage(dentistService: widget.dentistService),
    2 => PatientsPage(patientService: widget.patientService),
    3 => OrdersPage(orderService: widget.orderService),
    4 => InventoryPage(inventoryService: widget.inventoryService),
    _ => AgendaPage(agendaService: widget.agendaService),
  };
}
