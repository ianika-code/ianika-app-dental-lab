import '../data/agenda_repository.dart';
import '../data/dentist_repository.dart';
import '../data/order_repository.dart';
import '../models/agenda_event.dart';
import '../models/dentist.dart';
import '../models/lab_order.dart';
import 'file_logger.dart';
import 'service_exception.dart';

class AgendaService {
  const AgendaService(
    this._events,
    this._orders,
    this._dentists,
    this._logger,
  );

  final AgendaRepository _events;
  final OrderRepository _orders;
  final DentistRepository _dentists;
  final FileLogger _logger;

  Future<List<AgendaEvent>> getAll() async {
    try {
      return await _events.getAll();
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar agenda', error, stackTrace);
      rethrow;
    }
  }

  Future<List<AgendaEvent>> getUpcoming({int days = 7}) async {
    try {
      return await _events.getUpcoming(days: days);
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar próximos eventos', error, stackTrace);
      rethrow;
    }
  }

  Future<List<LabOrder>> getOrders() async {
    try {
      return await _orders.getAll();
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar pedidos para agenda', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Dentist>> getDentists() async {
    try {
      return await _dentists.getAll();
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao carregar dentistas para agenda',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> create(AgendaEventInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      await _validateReferences(normalized);
      await _events.create(normalized);
      _logger.info('Evento criado: ${normalized.title}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao criar evento ${normalized.title}', error, stackTrace);
      rethrow;
    }
  }

  Future<void> update(String id, AgendaEventInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      await _validateReferences(normalized);
      if (await _events.update(id, normalized) == 0) {
        throw const ServiceException('Evento não encontrado.');
      }
      _logger.info('Evento atualizado: ${normalized.title}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao atualizar evento $id', error, stackTrace);
      rethrow;
    }
  }

  Future<void> markCompleted(AgendaEvent event) async {
    try {
      if (await _events.markCompleted(event.id) == 0) {
        throw const ServiceException('O evento já foi concluído ou não existe.');
      }
      _logger.info('Evento concluído: ${event.title}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao concluir evento ${event.id}', error, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(AgendaEvent event) async {
    try {
      if (await _events.softDelete(event.id) == 0) {
        throw const ServiceException('Evento não encontrado.');
      }
      _logger.info('Evento removido: ${event.title}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao remover evento ${event.id}', error, stackTrace);
      rethrow;
    }
  }

  AgendaEventInput _normalize(AgendaEventInput input) => AgendaEventInput(
        type: input.type,
        title: input.title.trim(),
        description: _nullableText(input.description),
        dateTime: input.dateTime,
        orderId: _nullableText(input.orderId),
        dentistId: _nullableText(input.dentistId),
      );

  void _validate(AgendaEventInput input) {
    if (input.title.isEmpty || input.title.length > 200) {
      throw const ServiceException('Título é obrigatório (até 200 caracteres).');
    }
  }

  Future<void> _validateReferences(AgendaEventInput input) async {
    if (!await _events.orderExists(input.orderId)) {
      throw const ServiceException('O pedido associado não foi encontrado.');
    }
    if (!await _events.dentistExists(input.dentistId)) {
      throw const ServiceException('O dentista associado não foi encontrado.');
    }
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
