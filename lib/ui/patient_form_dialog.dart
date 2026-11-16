import 'package:material_ui/material_ui.dart';

import '../models/dentist.dart';
import '../models/patient.dart';
import 'ui_formatters.dart';

class PatientFormDialog extends StatefulWidget {
  const PatientFormDialog({required this.dentists, this.patient, super.key});

  final List<Dentist> dentists;
  final Patient? patient;

  @override
  State<PatientFormDialog> createState() => _PatientFormDialogState();
}

class _PatientFormDialogState extends State<PatientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _cpf;
  late final TextEditingController _phone;
  late final TextEditingController _notes;
  late DateTime _birthDate;
  String? _dentistId;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    _name = TextEditingController(text: patient?.name ?? '');
    _cpf = TextEditingController(
      text: patient == null ? '' : formatCpf(patient.cpf),
    );
    _phone = TextEditingController(text: patient?.phone ?? '');
    _notes = TextEditingController(text: patient?.notes ?? '');
    _birthDate = patient?.birthDate ?? DateTime(2000, 1, 1);
    _dentistId = patient?.dentistId ?? widget.dentists.firstOrNull?.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _cpf.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate.isBefore(today)
          ? _birthDate
          : DateTime(today.year - 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year, today.month, today.day - 1),
      helpText: 'Selecione a data de nascimento',
    );
    if (selected != null) setState(() => _birthDate = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      PatientInput(
        name: _name.text,
        cpf: _cpf.text,
        phone: _phone.text,
        birthDate: _birthDate,
        dentistId: _dentistId!,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.patient == null ? 'Novo paciente' : 'Editar paciente'),
    content: SizedBox(
      width: 540,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  counterText: '',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nome é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cpf,
                maxLength: 14,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                  counterText: '',
                ),
                validator: (value) {
                  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length == 11
                      ? null
                      : 'Informe os 11 dígitos do CPF.';
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                maxLength: 20,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  counterText: '',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Telefone é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _selectBirthDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text('Nascimento: ${formatDate(_birthDate)}'),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _dentistId,
                decoration: const InputDecoration(
                  labelText: 'Dentista responsável',
                ),
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
                    value == null ? 'Selecione um dentista responsável.' : null,
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
