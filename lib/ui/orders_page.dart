import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/lab_order.dart';
import '../services/order_service.dart';
import 'order_form_dialog.dart';
import 'ui_formatters.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({required this.orderService, super.key});

  final OrderService orderService;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<LabOrder> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await widget.orderService.getAll(search: _search.text);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _load);
  }

  Future<void> _create() => _openForm();

  Future<void> _edit(LabOrder order) => _openForm(order: order);

  Future<void> _openForm({LabOrder? order}) async {
    try {
      final patients = await widget.orderService.getPatients();
      final dentists = await widget.orderService.getDentists();
      if (!mounted) return;
      if (patients.isEmpty || dentists.isEmpty) {
        _message(
          'Cadastre ao menos um paciente e um dentista antes de criar pedidos.',
          isError: true,
        );
        return;
      }
      final suggestedNumber =
          order?.number ?? await widget.orderService.nextOrderNumber();
      if (!mounted) return;
      final input = await showDialog<LabOrderInput>(
        context: context,
        builder: (context) => OrderFormDialog(
          patients: patients,
          dentists: dentists,
          suggestedNumber: suggestedNumber,
          order: order,
        ),
      );
      if (input == null || !mounted) return;
      if (order == null) {
        await widget.orderService.create(input);
      } else {
        await widget.orderService.update(order.id, input);
      }
      await _load();
      if (mounted) {
        _message(order == null ? 'Pedido cadastrado.' : 'Pedido atualizado.');
      }
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _updateStatus(LabOrder order, OrderStatus status) async {
    try {
      await widget.orderService.updateStatus(order, status);
      await _load();
      if (mounted) _message('Status atualizado para ${status.label}.');
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _delete(LabOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir pedido?'),
        content: Text('O pedido ${order.number} será ocultado da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.orderService.delete(order);
      await _load();
      if (mounted) _message('Pedido excluído.');
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  void _message(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pedidos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Novo pedido'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 440,
          child: TextField(
            controller: _search,
            onChanged: _searchChanged,
            decoration: InputDecoration(
              labelText: 'Pesquisar por número, paciente ou dentista',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: () {
                  _search.clear();
                  _load();
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(clipBehavior: Clip.antiAlias, child: _content()),
        ),
      ],
    ),
  );

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Erro ao carregar pedidos: $_error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Text(
          _search.text.trim().isEmpty
              ? 'Nenhum pedido cadastrado.'
              : 'Nenhum pedido encontrado.',
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nº pedido')),
              DataColumn(label: Text('Paciente')),
              DataColumn(label: Text('Dentista')),
              DataColumn(label: Text('Prótese')),
              DataColumn(label: Text('Previsão')),
              DataColumn(label: Text('Valor')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Ações')),
            ],
            rows: _orders.map((order) {
              return DataRow(
                cells: [
                  DataCell(Text(order.number)),
                  DataCell(Text(order.patientName)),
                  DataCell(Text(order.dentistName)),
                  DataCell(Text(order.prosthesisType)),
                  DataCell(Text(formatDate(order.expectedDate))),
                  DataCell(Text(formatCurrency(order.value))),
                  DataCell(
                    DropdownButton<OrderStatus>(
                      value: order.status,
                      underline: const SizedBox.shrink(),
                      items: OrderStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (status) {
                        if (status != null && status != order.status) {
                          _updateStatus(order, status);
                        }
                      },
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => _edit(order),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          onPressed: () => _delete(order),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
