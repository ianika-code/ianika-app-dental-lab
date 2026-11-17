import 'package:material_ui/material_ui.dart';

import '../models/agenda_event.dart';
import '../models/dentist.dart';
import '../models/lab_order.dart';
import 'ui_formatters.dart';

class AgendaEventFormDialog extends StatefulWidget {
  const AgendaEventFormDialog({
    required this.orders,
    required this.dentists,
    this.event,
    super.key,
  });

  final List<LabOrder> orders;
  final List<Dentist> dentists;
  final AgendaEvent? event;

  @override
  State<AgendaEventFormDialog> createState() => _AgendaEventFormDialogState();
}

class _AgendaEventFormDialogState extends State<AgendaEventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late AgendaEventType _type;
  late DateTime _dateTime;
  String? _orderId;
  String? _dentistId;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _title = TextEditingController(text: event?.title ?? '');
    _description = TextEditingController(text: event?.description ?? '');
    _type = event?.type ?? AgendaEventType.reminder;
    _dateTime = event?.dateTime.toLocal() ??
        DateTime.now().add(const Duration(hours: 1));
    _orderId = event?.orderId;
    _dentistId = event?.dentistId;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Data do evento',
    );
    if (selected == null) return;
    setState(() {
      _dateTime = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
      helpText: 'Horário do evento',
    );
    if (selected == null) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        selected.hour,
        selected.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      AgendaEventInput(
        type: _type,
        title: _title.text,
        description: _description.text,
        dateTime: _dateTime,
        orderId: _orderId,
        dentistId: _dentistId,
      ),
    );
  }

  List<DropdownMenuItem<String?>> _orderOptions() {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(value: null, child: Text('Nenhum pedido associado')),
    ];
    if (_orderId != null && !widget.orders.any((order) => order.id == _orderId)) {
      items.add(DropdownMenuItem(
        value: _orderId,
        child: const Text('Pedido indisponível (remova a associação)'),
      ));
    }
    items.addAll(
      widget.orders.map(
        (order) => DropdownMenuItem<String?>(
          value: order.id,
          child: Text('${order.number} • ${order.patientName}'),
        ),
      ),
    );
    return items;
  }

  List<DropdownMenuItem<String?>> _dentistOptions() {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(
        value: null,
        child: Text('Nenhum dentista associado'),
      ),
    ];
    if (_dentistId != null &&
        !widget.dentists.any((dentist) => dentist.id == _dentistId)) {
      items.add(DropdownMenuItem(
        value: _dentistId,
        child: const Text('Dentista indisponível (remova a associação)'),
      ));
    }
    items.addAll(
      widget.dentists.map(
        (dentist) => DropdownMenuItem<String?>(
          value: dentist.id,
          child: Text('${dentist.name} • CRO ${dentist.cro}'),
        ),
      ),
    );
    return items;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.event == null ? 'Novo evento' : 'Editar evento'),
        content: SizedBox(
          width: 560,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _title,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      counterText: '',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Título é obrigatório.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<AgendaEventType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Tipo de evento'),
                    items: AgendaEventType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ))
                        .toList(),
                    onChanged: (type) {
                      if (type != null) setState(() => _type = type);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(formatDate(_dateTime)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(TimeOfDay.fromDateTime(_dateTime).format(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String?>(
                    initialValue: _orderId,
                    decoration: const InputDecoration(labelText: 'Pedido (opcional)'),
                    hint: const Text('Nenhum pedido associado'),
                    items: _orderOptions(),
                    onChanged: (value) => setState(() => _orderId = value),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String?>(
                    initialValue: _dentistId,
                    decoration: const InputDecoration(labelText: 'Dentista (opcional)'),
                    hint: const Text('Nenhum dentista associado'),
                    items: _dentistOptions(),
                    onChanged: (value) => setState(() => _dentistId = value),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(onPressed: _save, child: const Text('Salvar')),
        ],
      );
}
