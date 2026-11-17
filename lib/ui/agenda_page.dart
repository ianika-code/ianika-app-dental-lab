import 'package:material_ui/material_ui.dart';

import '../models/agenda_event.dart';
import '../services/agenda_service.dart';
import 'agenda_event_form_dialog.dart';
import 'ui_formatters.dart';

enum _AgendaFilter { all, nextWeek, pending, completed }

class AgendaPage extends StatefulWidget {
  const AgendaPage({required this.agendaService, super.key});

  final AgendaService agendaService;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<AgendaEvent> _events = [];
  _AgendaFilter _filter = _AgendaFilter.all;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final events = await widget.agendaService.getAll();
      if (!mounted) return;
      setState(() {
        _events = events;
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

  Future<void> _openForm({AgendaEvent? event}) async {
    try {
      final orders = await widget.agendaService.getOrders();
      final dentists = await widget.agendaService.getDentists();
      if (!mounted) return;
      final input = await showDialog<AgendaEventInput>(
        context: context,
        builder: (context) => AgendaEventFormDialog(
          orders: orders,
          dentists: dentists,
          event: event,
        ),
      );
      if (input == null || !mounted) return;
      if (event == null) {
        await widget.agendaService.create(input);
      } else {
        await widget.agendaService.update(event.id, input);
      }
      await _load();
      if (mounted) {
        _message(event == null ? 'Evento cadastrado.' : 'Evento atualizado.');
      }
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _complete(AgendaEvent event) async {
    try {
      await widget.agendaService.markCompleted(event);
      await _load();
      if (mounted) _message('Evento marcado como concluído.');
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _delete(AgendaEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir evento?'),
        content: Text('O evento "${event.title}" será removido da agenda.'),
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
      await widget.agendaService.delete(event);
      await _load();
      if (mounted) _message('Evento excluído.');
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

  List<AgendaEvent> get _filteredEvents {
    final now = DateTime.now();
    final end = now.add(const Duration(days: 7));
    return _events.where((event) {
      switch (_filter) {
        case _AgendaFilter.all:
          return true;
        case _AgendaFilter.nextWeek:
          return !event.completed &&
              !event.dateTime.isBefore(now) &&
              !event.dateTime.isAfter(end);
        case _AgendaFilter.pending:
          return !event.completed;
        case _AgendaFilter.completed:
          return event.completed;
      }
    }).toList();
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
                'Agenda',
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
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Novo evento'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<_AgendaFilter>(
            segments: const [
              ButtonSegment(
                value: _AgendaFilter.all,
                label: Text('Todos'),
                icon: Icon(Icons.event_note),
              ),
              ButtonSegment(
                value: _AgendaFilter.nextWeek,
                label: Text('Próximos 7 dias'),
                icon: Icon(Icons.upcoming_outlined),
              ),
              ButtonSegment(
                value: _AgendaFilter.pending,
                label: Text('Pendentes'),
                icon: Icon(Icons.pending_outlined),
              ),
              ButtonSegment(
                value: _AgendaFilter.completed,
                label: Text('Concluídos'),
                icon: Icon(Icons.task_alt),
              ),
            ],
            selected: {_filter},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _filter = selection.first),
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
            Text('Erro ao carregar agenda: $_error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    final events = _filteredEvents;
    if (events.isEmpty) {
      return Center(
        child: Text(switch (_filter) {
          _AgendaFilter.nextWeek =>
            'Nenhum evento previsto para os próximos 7 dias.',
          _AgendaFilter.pending => 'Nenhum evento pendente.',
          _AgendaFilter.completed => 'Nenhum evento concluído.',
          _AgendaFilter.all => 'Nenhum evento cadastrado na agenda.',
        }),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Data e hora')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Evento')),
                DataColumn(label: Text('Pedido')),
                DataColumn(label: Text('Dentista')),
                DataColumn(label: Text('Situação')),
                DataColumn(label: Text('Ações')),
              ],
              rows: events.map((event) {
                return DataRow(
                  cells: [
                    DataCell(Text(formatDateTime(event.dateTime))),
                    DataCell(Text(event.type.label)),
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          event.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(event.orderNumber ?? '—')),
                    DataCell(Text(event.dentistName ?? '—')),
                    DataCell(
                      Chip(
                        label: Text(event.completed ? 'Concluído' : 'Pendente'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!event.completed)
                            IconButton(
                              tooltip: 'Marcar como concluído',
                              onPressed: () => _complete(event),
                              icon: const Icon(Icons.check_circle_outline),
                            ),
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => _openForm(event: event),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            onPressed: () => _delete(event),
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
      ),
    );
  }
}
