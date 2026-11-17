import '../data/inventory_repository.dart';
import '../models/inventory_item.dart';
import '../models/stock_movement.dart';
import 'file_logger.dart';
import 'service_exception.dart';

const _maximumStockQuantity = 2147483647;

class InventoryService {
  const InventoryService(this._repository, this._logger);

  final InventoryRepository _repository;
  final FileLogger _logger;

  Future<List<InventoryItem>> getAll({
    String search = '',
    StockCategory? category,
    bool lowOnly = false,
  }) async {
    try {
      return await _repository.getAll(
        search: search,
        category: category,
        lowOnly: lowOnly,
      );
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar o estoque', error, stackTrace);
      rethrow;
    }
  }

  Future<List<InventoryItem>> getLowStock() async {
    try {
      return await _repository.getLowStock();
    } catch (error, stackTrace) {
      _logger.error('Falha ao consultar itens com estoque baixo', error, stackTrace);
      rethrow;
    }
  }

  Future<void> create(InventoryItemInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      if (await _repository.nameExists(normalized.name)) {
        throw const ServiceException('Já existe um item ativo com esse nome.');
      }
      await _repository.create(normalized);
      _logger.info('Item de estoque cadastrado: ${normalized.name}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao cadastrar item ${normalized.name}', error, stackTrace);
      rethrow;
    }
  }

  Future<void> update(String id, InventoryItemInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      final current = await _repository.getById(id);
      if (current == null) throw const ServiceException('Item não encontrado.');
      if (current.name.toLowerCase() != normalized.name.toLowerCase() &&
          await _repository.nameExists(normalized.name, excludingId: id)) {
        throw const ServiceException('Já existe um item ativo com esse nome.');
      }
      if (await _repository.update(id, normalized) == 0) {
        throw const ServiceException('Item não encontrado.');
      }
      _logger.info('Item de estoque atualizado: ${normalized.name}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao atualizar item $id', error, stackTrace);
      rethrow;
    }
  }

  Future<InventoryItem> registerMovement(StockMovementInput input) async {
    final normalized = StockMovementInput(
      itemId: input.itemId,
      type: input.type,
      quantity: input.quantity,
      reason: input.reason.trim(),
      notes: input.notes?.trim(),
    );
    try {
      if (normalized.quantity <= 0) {
        throw const ServiceException('A quantidade deve ser maior que zero.');
      }
      if (normalized.quantity > _maximumStockQuantity) {
        throw const ServiceException('A quantidade excede o limite suportado.');
      }
      if (normalized.reason.isEmpty || normalized.reason.length > 200) {
        throw const ServiceException('O motivo é obrigatório (até 200 caracteres).');
      }
      final item = await _repository.recordMovement(normalized);
      _logger.info(
        '${normalized.type.label} no estoque: ${item.name}, '
        'quantidade ${normalized.quantity}, motivo: ${normalized.reason}',
      );
      return item;
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao registrar ${normalized.type.label.toLowerCase()} '
        'para o item ${normalized.itemId}',
        error,
        stackTrace,
      );
      if (error is StateError) {
        throw ServiceException(error.message.toString());
      }
      rethrow;
    }
  }

  Future<List<StockMovement>> getHistory(String itemId) async {
    try {
      return await _repository.getHistory(itemId);
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar histórico do item $itemId', error, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(InventoryItem item) async {
    try {
      if (await _repository.softDelete(item.id) == 0) {
        throw const ServiceException('Item não encontrado.');
      }
      _logger.info('Item de estoque removido: ${item.name}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao remover item ${item.id}', error, stackTrace);
      rethrow;
    }
  }

  InventoryItemInput _normalize(InventoryItemInput input) => InventoryItemInput(
        name: input.name.trim(),
        category: input.category,
        minimumQuantity: input.minimumQuantity,
        unit: input.unit.trim(),
        unitPrice: input.unitPrice,
        description: _nullableText(input.description),
        supplier: _nullableText(input.supplier),
      );

  void _validate(InventoryItemInput input) {
    if (input.name.isEmpty || input.name.length > 150) {
      throw const ServiceException('Nome é obrigatório (até 150 caracteres).');
    }
    if (input.minimumQuantity < 0) {
      throw const ServiceException('A quantidade mínima não pode ser negativa.');
    }
    if (input.minimumQuantity > _maximumStockQuantity) {
      throw const ServiceException('A quantidade mínima excede o limite suportado.');
    }
    if (input.unit.isEmpty || input.unit.length > 20) {
      throw const ServiceException('Unidade é obrigatória (até 20 caracteres).');
    }
    if (!input.unitPrice.isFinite || input.unitPrice < 0) {
      throw const ServiceException('O valor unitário não pode ser negativo.');
    }
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
