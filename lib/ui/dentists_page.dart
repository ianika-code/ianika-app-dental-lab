import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/dentist.dart';
import '../services/dentist_service.dart';
import 'dentist_form_dialog.dart';

class DentistsPage extends StatefulWidget {
  const DentistsPage({required this.dentistService, super.key});

  final DentistService dentistService;

  @override
  State<DentistsPage> createState() => _DentistsPageState();
}

class _DentistsPageState extends State<DentistsPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Dentist> _dentists = [];
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
      final result = await widget.dentistService.getAll(search: _search.text);
      if (!mounted) return;
      setState(() {
        _dentists = result;
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

  Future<void> _create() async {
    final input = await showDialog<DentistInput>(
      context: context,
      builder: (context) => const DentistFormDialog(),
    );
    if (input == null || !mounted) return;
    await _runAction(
      () => widget.dentistService.create(input),
      'Dentista cadastrado.',
    );
  }

  Future<void> _edit(Dentist dentist) async {
    final input = await showDialog<DentistInput>(
      context: context,
      builder: (context) => DentistFormDialog(dentist: dentist),
    );
    if (input == null || !mounted) return;
    await _runAction(
      () => widget.dentistService.update(dentist.id, input),
      'Dentista atualizado.',
    );
  }

  Future<void> _delete(Dentist dentist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir dentista?'),
        content: Text('O cadastro de ${dentist.name} será removido da lista.'),
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
    await _runAction(
      () => widget.dentistService.delete(dentist),
      'Dentista excluído.',
    );
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String success,
  ) async {
    try {
      await action();
      await _load();
      if (mounted) _message(success);
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
                'Cadastro de dentistas',
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
              label: const Text('Novo dentista'),
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
              labelText: 'Pesquisar por nome ou CRO',
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
        child: TextButton(onPressed: _load, child: Text('Erro: $_error')),
      );
    }
    if (_dentists.isEmpty) {
      return Center(
        child: Text(
          _search.text.isEmpty
              ? 'Nenhum dentista cadastrado.'
              : 'Nenhum dentista encontrado.',
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
              DataColumn(label: Text('CRO')),
              DataColumn(label: Text('Telefone')),
              DataColumn(label: Text('E-mail')),
              DataColumn(label: Text('Endereço')),
              DataColumn(label: Text('Ações')),
            ],
            rows: _dentists
                .map(
                  (dentist) => DataRow(
                    cells: [
                      DataCell(Text(dentist.name)),
                      DataCell(Text(dentist.cro)),
                      DataCell(Text(dentist.phone)),
                      DataCell(Text(dentist.email)),
                      DataCell(Text(dentist.address)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => _edit(dentist),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              onPressed: () => _delete(dentist),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
