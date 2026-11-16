import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';
import 'patient_form_dialog.dart';
import 'ui_formatters.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({required this.patientService, super.key});

  final PatientService patientService;

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Patient> _patients = [];
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
      final patients = await widget.patientService.getAll(search: _search.text);
      if (!mounted) return;
      setState(() {
        _patients = patients;
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

  Future<void> _edit(Patient patient) => _openForm(patient: patient);

  Future<void> _openForm({Patient? patient}) async {
    try {
      final dentists = await widget.patientService.getDentists();
      if (!mounted) return;
      if (dentists.isEmpty) {
        _message(
          'Cadastre ao menos um dentista antes de cadastrar pacientes.',
          isError: true,
        );
        return;
      }
      final input = await showDialog<PatientInput>(
        context: context,
        builder: (context) =>
            PatientFormDialog(dentists: dentists, patient: patient),
      );
      if (input == null || !mounted) return;
      if (patient == null) {
        await widget.patientService.create(input);
      } else {
        await widget.patientService.update(patient.id, input);
      }
      await _load();
      if (mounted) {
        _message(
          patient == null ? 'Paciente cadastrado.' : 'Paciente atualizado.',
        );
      }
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _delete(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir paciente?'),
        content: Text(
          'O cadastro de ${patient.name} será ocultado. '
          'Os pedidos existentes serão mantidos.',
        ),
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
      await widget.patientService.delete(patient);
      await _load();
      if (mounted) _message('Paciente excluído.');
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
                'Cadastro de pacientes',
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
              label: const Text('Novo paciente'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 420,
          child: TextField(
            controller: _search,
            onChanged: _searchChanged,
            decoration: InputDecoration(
              labelText: 'Pesquisar por nome ou CPF',
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
            Text('Erro ao carregar pacientes: $_error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_patients.isEmpty) {
      return Center(
        child: Text(
          _search.text.trim().isEmpty
              ? 'Nenhum paciente cadastrado.'
              : 'Nenhum paciente encontrado.',
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nome')),
              DataColumn(label: Text('CPF')),
              DataColumn(label: Text('Telefone')),
              DataColumn(label: Text('Nascimento')),
              DataColumn(label: Text('Dentista responsável')),
              DataColumn(label: Text('Ações')),
            ],
            rows: _patients.map((patient) {
              return DataRow(
                cells: [
                  DataCell(Text(patient.name)),
                  DataCell(Text(formatCpf(patient.cpf))),
                  DataCell(Text(patient.phone)),
                  DataCell(Text(formatDate(patient.birthDate))),
                  DataCell(Text(patient.dentistName)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => _edit(patient),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          onPressed: () => _delete(patient),
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
