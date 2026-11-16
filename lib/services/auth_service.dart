import 'package:bcrypt/bcrypt.dart';

import '../data/user_repository.dart';
import '../models/app_user.dart';
import 'file_logger.dart';

class AuthService {
  const AuthService(this._repository, this._logger);

  final UserRepository _repository;
  final FileLogger _logger;

  Future<AppUser?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return null;
    try {
      final row = await _repository.findByEmail(email);
      if (row == null || row['Ativo'] != 1) {
        _logger.warning('Login recusado para ${email.trim()}');
        return null;
      }
      if (!BCrypt.checkpw(password, row['SenhaHash']! as String)) {
        _logger.warning('Senha incorreta para ${email.trim()}');
        return null;
      }

      final user = _repository.toAppUser(row);
      await _repository.updateLastLogin(user.id, DateTime.now().toUtc());
      _logger.info('Login realizado: ${user.email}');
      return user;
    } catch (error, stackTrace) {
      _logger.error('Falha ao autenticar ${email.trim()}', error, stackTrace);
      rethrow;
    }
  }
}
