import '../data/dentist_repository.dart';
import '../models/dentist.dart';
import 'file_logger.dart';
import 'service_exception.dart';

class DentistService {
  const DentistService(this._repository, this._logger);

  final DentistRepository _repository;
  final FileLogger _logger;

  Future<List<Dentist>> getAll({String search = ''}) async {
    try {
      return await _repository.getAll(search: search);
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar dentistas', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Dentist>> getAllForForm() async {
    try {
      return await _repository.getAll();
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao carregar dentistas para formulário',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> create(DentistInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      if (await _repository.croExists(normalized.cro)) {
        throw const ServiceException('CRO já cadastrado no sistema.');
      }
      await _repository.create(normalized);
      _logger.info('Dentista cadastrado: ${normalized.name}');
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao cadastrar dentista ${normalized.name}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> update(String id, DentistInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      if (await _repository.croExists(normalized.cro, excludingId: id)) {
        throw const ServiceException('CRO já cadastrado no sistema.');
      }
      if (await _repository.update(id, normalized) == 0) {
        throw const ServiceException('Dentista não encontrado.');
      }
      _logger.info('Dentista atualizado: ${normalized.name}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao atualizar dentista $id', error, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(Dentist dentist) async {
    try {
      if (await _repository.hasLinkedPatients(dentist.id) ||
          await _repository.hasLinkedOrders(dentist.id)) {
        throw const ServiceException(
          'Não é possível excluir um dentista com pacientes ou pedidos vinculados.',
        );
      }
      if (await _repository.softDelete(dentist.id) == 0) {
        throw const ServiceException('Dentista não encontrado.');
      }
      _logger.info('Dentista excluído: ${dentist.name}');
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao excluir dentista ${dentist.id}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  DentistInput _normalize(DentistInput input) => DentistInput(
    name: input.name.trim(),
    cro: input.cro.trim(),
    phone: input.phone.trim(),
    email: input.email.trim(),
    address: input.address.trim(),
    notes: input.notes?.trim(),
  );

  void _validate(DentistInput input) {
    if (input.name.isEmpty || input.name.length > 150) {
      throw const ServiceException('Nome é obrigatório (até 150 caracteres).');
    }
    if (!RegExp(r'^\d{1,20}$').hasMatch(input.cro)) {
      throw const ServiceException(
        'CRO deve conter apenas números (até 20 dígitos).',
      );
    }
    if (input.phone.isEmpty || input.phone.length > 20) {
      throw const ServiceException(
        'Telefone é obrigatório (até 20 caracteres).',
      );
    }
    if (input.email.length > 150 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input.email)) {
      throw const ServiceException(
        'Informe um e-mail válido (até 150 caracteres).',
      );
    }
    if (input.address.isEmpty || input.address.length > 300) {
      throw const ServiceException(
        'Endereço é obrigatório (até 300 caracteres).',
      );
    }
  }
}
