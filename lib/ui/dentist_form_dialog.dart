import 'package:material_ui/material_ui.dart';

import '../models/dentist.dart';

class DentistFormDialog extends StatefulWidget {
  const DentistFormDialog({this.dentist, super.key});

  final Dentist? dentist;

  @override
  State<DentistFormDialog> createState() => _DentistFormDialogState();
}

class _DentistFormDialogState extends State<DentistFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _cro;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final dentist = widget.dentist;
    _name = TextEditingController(text: dentist?.name ?? '');
    _cro = TextEditingController(text: dentist?.cro ?? '');
    _phone = TextEditingController(text: dentist?.phone ?? '');
    _email = TextEditingController(text: dentist?.email ?? '');
    _address = TextEditingController(text: dentist?.address ?? '');
    _notes = TextEditingController(text: dentist?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _cro.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      DentistInput(
        name: _name.text,
        cro: _cro.text,
        phone: _phone.text,
        email: _email.text,
        address: _address.text,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.dentist == null ? 'Novo dentista' : 'Editar dentista'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_name, 'Nome', maxLength: 150),
              _field(_cro, 'CRO', maxLength: 20, numeric: true),
              _field(_phone, 'Telefone', maxLength: 20),
              _field(_email, 'E-mail', maxLength: 150, email: true),
              _field(_address, 'Endereço', maxLength: 300),
              _field(_notes, 'Observações', maxLines: 3),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    int? maxLength,
    int maxLines = 1,
    bool numeric = false,
    bool email = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: numeric
          ? TextInputType.number
          : email
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(labelText: label, counterText: ''),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (label != 'Observações' && text.isEmpty) {
          return '$label é obrigatório.';
        }
        if (numeric && !RegExp(r'^\d+$').hasMatch(text)) {
          return 'CRO deve conter apenas números.';
        }
        if (email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
          return 'Informe um e-mail válido.';
        }
        return null;
      },
    ),
  );
}
