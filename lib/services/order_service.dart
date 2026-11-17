import '../data/order_repository.dart';
import '../models/dentist.dart';
import '../models/lab_order.dart';
import '../models/patient.dart';
import 'file_logger.dart';
import 'service_exception.dart';

class OrderService {
  const OrderService(this._orders, this._logger);

  final OrderRepository _orders;
  final FileLogger _logger;

  Future<List<LabOrder>> getAll({String search = ''}) async {
    try {
      return await _orders.getAll(search: search);
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar pedidos', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Patient>> getPatients() async {
    try {
      return await _orders.getPatients();
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao carregar pacientes para pedido',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Dentist>> getDentists() async {
    try {
      return await _orders.getDentists();
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao carregar dentistas para pedido',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<String> nextOrderNumber() async {
    final now = DateTime.now();
    final prefix =
        'PED-${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-';
    late final String? latest;
    try {
      latest = await _orders.latestNumberForPrefix(prefix);
    } catch (error, stackTrace) {
      _logger.error('Falha ao gerar número do pedido', error, stackTrace);
      rethrow;
    }
    final sequence = latest == null
        ? 1
        : (int.tryParse(latest.substring(prefix.length)) ?? 0) + 1;
    return '$prefix${sequence.toString().padLeft(4, '0')}';
  }

  Future<void> create(LabOrderInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized, orderDate: DateTime.now());
      if (!await _orders.referencesExist(
        normalized.patientId,
        normalized.dentistId,
      )) {
        throw const ServiceException(
          'Selecione um paciente e um dentista ativos.',
        );
      }
      if (await _orders.numberExists(normalized.number)) {
        throw const ServiceException('Número do pedido já existe.');
      }
      await _orders.create(normalized);
      _logger.info('Pedido criado: ${normalized.number}');
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao criar pedido ${normalized.number}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> update(String id, LabOrderInput input) async {
    final normalized = _normalize(input);
    try {
      final current = await _orders.getById(id);
      if (current == null) {
        throw const ServiceException('Pedido não encontrado.');
      }
      _validate(normalized, orderDate: current.orderDate);
      if (!await _orders.referencesExist(
        normalized.patientId,
        normalized.dentistId,
      )) {
        throw const ServiceException(
          'Selecione um paciente e um dentista ativos.',
        );
      }
      if (current.number.toLowerCase() != normalized.number.toLowerCase() &&
          await _orders.numberExists(normalized.number, excludingId: id)) {
        throw const ServiceException('Número do pedido já existe.');
      }
      if (await _orders.update(id, normalized) == 0) {
        throw const ServiceException('Pedido não encontrado.');
      }
      _logger.info('Pedido atualizado: ${normalized.number}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao atualizar pedido $id', error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateStatus(LabOrder order, OrderStatus status) async {
    try {
      if (await _orders.getById(order.id) == null) {
        throw const ServiceException('Pedido não encontrado.');
      }
      if (await _orders.updateStatus(order.id, status) == 0) {
        throw const ServiceException('Pedido não encontrado.');
      }
      _logger.info(
        'Status do pedido ${order.number} alterado para ${status.label}',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao atualizar status do pedido ${order.number}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> delete(LabOrder order) async {
    try {
      if (await _orders.softDelete(order.id) == 0) {
        throw const ServiceException('Pedido não encontrado.');
      }
      _logger.info('Pedido excluído: ${order.number}');
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao excluir pedido ${order.number}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  LabOrderInput _normalize(LabOrderInput input) => LabOrderInput(
    number: input.number.trim(),
    patientId: input.patientId,
    dentistId: input.dentistId,
    prosthesisType: input.prosthesisType.trim(),
    expectedDate: DateTime(
      input.expectedDate.year,
      input.expectedDate.month,
      input.expectedDate.day,
    ),
    value: input.value,
    notes: input.notes?.trim(),
  );

  void _validate(LabOrderInput input, {required DateTime orderDate}) {
    if (input.number.isEmpty || input.number.length > 50) {
      throw const ServiceException(
        'Número do pedido é obrigatório (até 50 caracteres).',
      );
    }
    if (input.patientId.isEmpty || input.dentistId.isEmpty) {
      throw const ServiceException('Paciente e dentista são obrigatórios.');
    }
    if (input.prosthesisType.isEmpty || input.prosthesisType.length > 100) {
      throw const ServiceException(
        'Tipo de prótese é obrigatório (até 100 caracteres).',
      );
    }
    if (!input.expectedDate.isAfter(
      DateTime(orderDate.year, orderDate.month, orderDate.day),
    )) {
      throw const ServiceException(
        'A data prevista deve ser posterior à data do pedido.',
      );
    }
    if (!input.value.isFinite || input.value <= 0) {
      throw const ServiceException('O valor deve ser maior que zero.');
    }
  }
}
