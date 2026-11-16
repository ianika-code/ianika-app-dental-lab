import 'package:material_ui/material_ui.dart';

import '../models/dentist.dart';
import '../models/lab_order.dart';
import '../models/patient.dart';
import 'ui_formatters.dart';

class OrderFormDialog extends StatefulWidget {
  const OrderFormDialog({
    required this.patients,
    required this.dentists,
    required this.suggestedNumber,
    this.order,
    super.key,
  });

  final List<Patient> patients;
  final List<Dentist> dentists;
  final String suggestedNumber;
  final LabOrder? order;

  @override
  State<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<OrderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _type;
  late final TextEditingController _value;
  late final TextEditingController _notes;
  late DateTime _expectedDate;
  late String? _patientId;
  late String? _dentistId;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _number = TextEditingController(
      text: order?.number ?? widget.suggestedNumber,
    );
    _type = TextEditingController(text: order?.prosthesisType ?? '');
    _value = TextEditingController(
      text: order == null
          ? ''
          : order.value.toStringAsFixed(2).replaceAll('.', ','),
    );
    _notes = TextEditingController(text: order?.notes ?? '');
    _expectedDate =
        order?.expectedDate ?? DateTime.now().add(const Duration(days: 1));
    _patientId = order?.patientId ?? widget.patients.firstOrNull?.id;
    _dentistId =
        order?.dentistId ??
        widget.patients
            .where((patient) => patient.id == _patientId)
            .firstOrNull
            ?.dentistId ??
        widget.dentists.firstOrNull?.id;
  }

  @override
  void dispose() {
    _number.dispose();
    _type.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _selectExpectedDate() async {
    final orderDate = widget.order?.orderDate ?? DateTime.now();
    final minDate = DateTime(
      orderDate.year,
      orderDate.month,
      orderDate.day + 1,
    );
    final initialDate = _expectedDate.isBefore(minDate)
        ? minDate
        : _expectedDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: DateTime(2100),
      helpText: 'Selecione a data prevista de entrega',
    );
    if (selected != null) setState(() => _expectedDate = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final value = parseCurrency(_value.text);
    if (value == null) return;
    Navigator.pop(
      context,
      LabOrderInput(
        number: _number.text,
        patientId: _patientId!,
        dentistId: _dentistId!,
        prosthesisType: _type.text,
        expectedDate: _expectedDate,
        value: value,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.order == null ? 'Novo pedido' : 'Editar pedido'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _number,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Número do pedido',
                  counterText: '',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Número do pedido é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _patientId,
                decoration: const InputDecoration(labelText: 'Paciente'),
                items: widget.patients
                    .map(
                      (patient) => DropdownMenuItem(
                        value: patient.id,
                        child: Text(
                          '${patient.name} • CPF ${formatCpf(patient.cpf)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _patientId = value;
                    final patient = widget.patients
                        .where((item) => item.id == value)
                        .firstOrNull;
                    if (patient != null) _dentistId = patient.dentistId;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione um paciente.' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _dentistId,
                decoration: const InputDecoration(labelText: 'Dentista'),
                items: widget.dentists
                    .map(
                      (dentist) => DropdownMenuItem(
                        value: dentist.id,
                        child: Text('${dentist.name} • CRO ${dentist.cro}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _dentistId = value),
                validator: (value) =>
                    value == null ? 'Selecione um dentista.' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _type,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Tipo de prótese',
                  hintText: 'Ex.: Coroa, Ponte, Prótese total',
                  counterText: '',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Tipo de prótese é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _selectExpectedDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text('Entrega prevista: ${formatDate(_expectedDate)}'),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                ),
                validator: (value) {
                  final parsed = parseCurrency(value ?? '');
                  return parsed == null || parsed <= 0
                      ? 'Informe um valor maior que zero.'
                      : null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  counterText: '',
                ),
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
