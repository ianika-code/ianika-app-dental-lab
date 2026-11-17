import '../data/patient_repository.dart';
import '../models/dentist.dart';
import '../models/patient.dart';
import 'file_logger.dart';
import 'service_exception.dart';

class PatientService {
  const PatientService(this._patients, this._logger);

  final PatientRepository _patients;
  final FileLogger _logger;

  Future<List<Patient>> getAll({String search = ''}) async {
    try {
      return await _patients.getAll(search: search);
    } catch (error, stackTrace) {
      _logger.error('Falha ao carregar pacientes', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Dentist>> getDentists() async {
    try {
      return await _patients.getDentists();
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao carregar dentistas para paciente',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> create(PatientInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      if (!await _patients.dentistExists(normalized.dentistId)) {
        throw const ServiceException('Dentista responsável não encontrado.');
      }
      if (await _patients.cpfExists(normalized.cpf)) {
        throw const ServiceException('CPF já cadastrado no sistema.');
      }
      await _patients.create(normalized);
      _logger.info('Paciente cadastrado: ${normalized.name}');
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao cadastrar paciente ${normalized.name}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> update(String id, PatientInput input) async {
    final normalized = _normalize(input);
    try {
      _validate(normalized);
      if (!await _patients.dentistExists(normalized.dentistId)) {
        throw const ServiceException('Dentista responsável não encontrado.');
      }
      final current = await _patients.getById(id);
      if (current == null) {
        throw const ServiceException('Paciente não encontrado.');
      }
      if (current.cpf != normalized.cpf &&
          await _patients.cpfExists(normalized.cpf, excludingId: id)) {
        throw const ServiceException('CPF já cadastrado no sistema.');
      }
      if (await _patients.update(id, normalized) == 0) {
        throw const ServiceException('Paciente não encontrado.');
      }
      _logger.info('Paciente atualizado: ${normalized.name}');
    } catch (error, stackTrace) {
      _logger.error('Falha ao atualizar paciente $id', error, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(Patient patient) async {
    try {
      if (await _patients.softDelete(patient.id) == 0) {
        throw const ServiceException('Paciente não encontrado.');
      }
      _logger.info('Paciente excluído: ${patient.name}');
    } catch (error, stackTrace) {
      _logger.error(
        'Falha ao excluir paciente ${patient.id}',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  PatientInput _normalize(PatientInput input) => PatientInput(
    name: input.name.trim(),
    cpf: input.cpf.replaceAll(RegExp(r'\D'), ''),
    phone: input.phone.trim(),
    birthDate: DateTime(
      input.birthDate.year,
      input.birthDate.month,
      input.birthDate.day,
    ),
    dentistId: input.dentistId,
    notes: input.notes?.trim(),
  );

  void _validate(PatientInput input) {
    if (input.name.isEmpty || input.name.length > 150) {
      throw const ServiceException('Nome é obrigatório (até 150 caracteres).');
    }
    if (!RegExp(r'^\d{11}$').hasMatch(input.cpf)) {
      throw const ServiceException('CPF deve conter 11 dígitos.');
    }
    if (input.phone.isEmpty || input.phone.length > 20) {
      throw const ServiceException(
        'Telefone é obrigatório (até 20 caracteres).',
      );
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (!input.birthDate.isBefore(todayDate)) {
      throw const ServiceException(
        'Data de nascimento deve ser anterior a hoje.',
      );
    }
    if (input.dentistId.isEmpty) {
      throw const ServiceException('Dentista responsável é obrigatório.');
    }
  }
}
