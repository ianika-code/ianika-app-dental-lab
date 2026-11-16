import 'package:material_ui/material_ui.dart';

import '../models/lab_order.dart';
import '../services/dentist_service.dart';
import '../services/order_service.dart';
import '../services/patient_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.dentistService,
    required this.patientService,
    required this.orderService,
    required this.onNavigate,
    super.key,
  });

  final DentistService dentistService;
  final PatientService patientService;
  final OrderService orderService;
  final ValueChanged<int> onNavigate;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardCounts> _counts;

  @override
  void initState() {
    super.initState();
    _counts = _loadCounts();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dentistService != widget.dentistService ||
        oldWidget.patientService != widget.patientService ||
        oldWidget.orderService != widget.orderService) {
      _counts = _loadCounts();
    }
  }

  Future<_DashboardCounts> _loadCounts() async {
    final dentists = await widget.dentistService.getAll();
    final patients = await widget.patientService.getAll();
    final orders = await widget.orderService.getAll();
    return _DashboardCounts(
      dentists: dentists.length,
      patients: patients.length,
      orders: orders.length,
      activeOrders: orders
          .where(
            (order) =>
                order.status != OrderStatus.finished &&
                order.status != OrderStatus.delivered,
          )
          .length,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_DashboardCounts>(
    future: _counts,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Não foi possível carregar o resumo: ${snapshot.error}'),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            'Resumo do laboratório',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse os cadastros e acompanhe os pedidos em andamento.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 4
                  : constraints.maxWidth > 650
                  ? 2
                  : 1;
              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: columns == 1 ? 3.2 : 1.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DashboardCard(
                    title: 'Dentistas',
                    count: snapshot.data?.dentists,
                    icon: Icons.people_outline,
                    onTap: () => widget.onNavigate(1),
                  ),
                  _DashboardCard(
                    title: 'Pacientes',
                    count: snapshot.data?.patients,
                    icon: Icons.person_outline,
                    onTap: () => widget.onNavigate(2),
                  ),
                  _DashboardCard(
                    title: 'Pedidos',
                    count: snapshot.data?.orders,
                    icon: Icons.assignment_outlined,
                    onTap: () => widget.onNavigate(3),
                  ),
                  _DashboardCard(
                    title: 'Em andamento',
                    count: snapshot.data?.activeOrders,
                    icon: Icons.pending_actions_outlined,
                    onTap: () => widget.onNavigate(3),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'O Dashboard agora dá acesso aos cadastros de dentistas, '
                      'pacientes e pedidos. Estoque e Agenda continuam previstos para uma próxima etapa.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _DashboardCounts {
  const _DashboardCounts({
    required this.dentists,
    required this.patients,
    required this.orders,
    required this.activeOrders,
  });

  final int dentists;
  final int patients;
  final int orders;
  final int activeOrders;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int? count;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(icon, color: colors.onPrimaryContainer),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    count?.toString() ?? '...',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
