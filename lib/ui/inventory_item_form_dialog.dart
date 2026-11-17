import 'package:material_ui/material_ui.dart';

import '../models/inventory_item.dart';
import '../models/stock_movement.dart';
import 'ui_formatters.dart';

class InventoryItemFormDialog extends StatefulWidget {
  const InventoryItemFormDialog({this.item, super.key});

  final InventoryItem? item;

  @override
  State<InventoryItemFormDialog> createState() =>
      _InventoryItemFormDialogState();
}

class _InventoryItemFormDialogState extends State<InventoryItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _minimum;
  late final TextEditingController _unit;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _supplier;
  late StockCategory _category;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _minimum = TextEditingController(
      text: item?.minimumQuantity.toString() ?? '0',
    );
    _unit = TextEditingController(text: item?.unit ?? 'unidade');
    _price = TextEditingController(
      text: item == null
          ? '0,00'
          : item.unitPrice.toStringAsFixed(2).replaceAll('.', ','),
    );
    _description = TextEditingController(text: item?.description ?? '');
    _supplier = TextEditingController(text: item?.supplier ?? '');
    _category = item?.category ?? StockCategory.resins;
  }

  @override
  void dispose() {
    _name.dispose();
    _minimum.dispose();
    _unit.dispose();
    _price.dispose();
    _description.dispose();
    _supplier.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      InventoryItemInput(
        name: _name.text,
        category: _category,
        minimumQuantity: int.parse(_minimum.text),
        unit: _unit.text,
        unitPrice: parseCurrency(_price.text)!,
        description: _description.text,
        supplier: _supplier.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          widget.item == null ? 'Novo item de estoque' : 'Editar item de estoque',
        ),
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
                      labelText: 'Nome do material',
                      counterText: '',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nome é obrigatório.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<StockCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: StockCategory.values
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minimum,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade mínima',
                          ),
                          validator: (value) {
                            final quantity = int.tryParse(value ?? '');
                            return quantity == null || quantity < 0
                                ? 'Informe zero ou mais.'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _unit,
                          maxLength: 20,
                          decoration: const InputDecoration(
                            labelText: 'Unidade (kg, un.)',
                            counterText: '',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Unidade é obrigatória.'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor unitário',
                      prefixText: 'R\$ ',
                    ),
                    validator: (value) {
                      final price = parseCurrency(value ?? '');
                      return price == null || price < 0
                          ? 'Informe um valor válido, zero ou maior.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _supplier,
                    decoration: const InputDecoration(labelText: 'Fornecedor'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _description,
                    maxLines: 2,
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

class StockMovementDialog extends StatefulWidget {
  const StockMovementDialog({
    required this.item,
    required this.type,
    super.key,
  });

  final InventoryItem item;
  final StockMovementType type;

  @override
  State<StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<StockMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _reason = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _quantity.dispose();
    _reason.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      StockMovementInput(
        itemId: widget.item.id,
        type: widget.type,
        quantity: int.parse(_quantity.text),
        reason: _reason.text,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('${widget.type.label} de material'),
        content: SizedBox(
          width: 430,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.item.name} • Disponível: '
                    '${widget.item.currentQuantity} ${widget.item.unit}',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantity,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                    suffixText: widget.item.unit,
                  ),
                  validator: (value) {
                    final quantity = int.tryParse(value ?? '');
                    if (quantity == null || quantity <= 0) {
                      return 'Informe uma quantidade maior que zero.';
                    }
                    if (widget.type == StockMovementType.exit &&
                        quantity > widget.item.currentQuantity) {
                      return 'Disponível: ${widget.item.currentQuantity}.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _reason,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    hintText: 'Compra, consumo, ajuste...',
                    counterText: '',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Motivo é obrigatório.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(onPressed: _save, child: Text(widget.type.label)),
        ],
      );
}

class StockHistoryDialog extends StatelessWidget {
  const StockHistoryDialog({
    required this.item,
    required this.movements,
    super.key,
  });

  final InventoryItem item;
  final List<StockMovement> movements;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Movimentações • ${item.name}'),
        content: SizedBox(
          width: 680,
          height: 420,
          child: movements.isEmpty
              ? const Center(child: Text('Nenhuma movimentação registrada.'))
              : ListView.separated(
                  itemCount: movements.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final isEntry = movement.type == StockMovementType.entry;
                    return ListTile(
                      leading: Icon(
                        isEntry ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isEntry
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        '${movement.type.label}: ${movement.quantity} ${item.unit}',
                      ),
                      subtitle: Text(
                        '${formatDateTime(movement.date)} • ${movement.reason}'
                        '${movement.notes == null ? '' : '\n${movement.notes}'}',
                      ),
                      isThreeLine: movement.notes != null,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      );
}
