import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/inventory_item.dart';
import '../models/stock_movement.dart';
import '../services/inventory_service.dart';
import 'inventory_item_form_dialog.dart';
import 'ui_formatters.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({required this.inventoryService, super.key});

  final InventoryService inventoryService;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<InventoryItem> _items = [];
  StockCategory? _category;
  bool _lowOnly = false;
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
      final items = await widget.inventoryService.getAll(
        search: _search.text,
        category: _category,
        lowOnly: _lowOnly,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _openForm({InventoryItem? item}) async {
    final input = await showDialog<InventoryItemInput>(
      context: context,
      builder: (context) => InventoryItemFormDialog(item: item),
    );
    if (input == null || !mounted) return;
    try {
      if (item == null) {
        await widget.inventoryService.create(input);
      } else {
        await widget.inventoryService.update(item.id, input);
      }
      await _load();
      if (mounted) {
        _message(item == null ? 'Item cadastrado.' : 'Item atualizado.');
      }
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _movement(InventoryItem item, StockMovementType type) async {
    final input = await showDialog<StockMovementInput>(
      context: context,
      builder: (context) => StockMovementDialog(item: item, type: type),
    );
    if (input == null || !mounted) return;
    try {
      await widget.inventoryService.registerMovement(input);
      await _load();
      if (mounted) _message('${type.label} registrada no estoque.');
    } catch (error) {
      if (mounted) _message('$error', isError: true);
    }
  }

  Future<void> _history(InventoryItem item) async {
    try {
      final movements = await widget.inventoryService.getHistory(item.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) =>
            StockHistoryDialog(item: item, movements: movements),
      );
    } catch (error) {
      if (mounted) {
        _message(
          'Não foi possível carregar o histórico: $error',
          isError: true,
        );
      }
    }
  }

  Future<void> _delete(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover item do estoque?'),
        content: Text(
          '${item.name} será ocultado do estoque. O histórico de movimentações será mantido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.inventoryService.delete(item);
      await _load();
      if (mounted) _message('Item removido.');
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
                'Estoque',
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
              label: const Text('Novo item'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 330,
              child: TextField(
                controller: _search,
                onChanged: _searchChanged,
                decoration: InputDecoration(
                  labelText: 'Pesquisar item ou fornecedor',
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
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: _category?.name ?? '',
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Todas as categorias'),
                  ),
                  ...StockCategory.values.map(
                    (category) => DropdownMenuItem<String>(
                      value: category.name,
                      child: Text(category.label),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value == null || value.isEmpty
                        ? null
                        : StockCategory.values.firstWhere(
                            (category) => category.name == value,
                          );
                  });
                  _load();
                },
              ),
            ),
            FilterChip(
              selected: _lowOnly,
              avatar: const Icon(Icons.warning_amber_outlined),
              label: const Text('Estoque baixo'),
              onSelected: (value) {
                setState(() => _lowOnly = value);
                _load();
              },
            ),
          ],
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
            Text('Erro ao carregar estoque: $_error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          _lowOnly
              ? 'Nenhum item com estoque baixo.'
              : _search.text.trim().isEmpty
              ? 'Nenhum item cadastrado no estoque.'
              : 'Nenhum item encontrado.',
        ),
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
                DataColumn(label: Text('Material')),
                DataColumn(label: Text('Categoria')),
                DataColumn(label: Text('Saldo')),
                DataColumn(label: Text('Mínimo')),
                DataColumn(label: Text('Valor unitário')),
                DataColumn(label: Text('Fornecedor')),
                DataColumn(label: Text('Ações')),
              ],
              rows: _items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name),
                          if (item.description != null)
                            Text(
                              item.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    DataCell(Text(item.category.label)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${item.currentQuantity} ${item.unit}'),
                          if (item.isLow) ...[
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Saldo no limite mínimo ou abaixo dele',
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    DataCell(Text('${item.minimumQuantity} ${item.unit}')),
                    DataCell(Text(formatCurrency(item.unitPrice))),
                    DataCell(Text(item.supplier ?? '—')),
                    DataCell(
                      Wrap(
                        spacing: 2,
                        children: [
                          IconButton(
                            tooltip: 'Registrar entrada',
                            onPressed: () =>
                                _movement(item, StockMovementType.entry),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          IconButton(
                            tooltip: 'Registrar saída',
                            onPressed: item.currentQuantity == 0
                                ? null
                                : () => _movement(item, StockMovementType.exit),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            tooltip: 'Histórico',
                            onPressed: () => _history(item),
                            icon: const Icon(Icons.history),
                          ),
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => _openForm(item: item),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Remover',
                            onPressed: () => _delete(item),
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
