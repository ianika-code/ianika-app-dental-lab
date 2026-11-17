import 'dart:developer' as developer;
import 'dart:io';

class FileLogger {
  FileLogger(String applicationDirectory)
    : _file = File(
        '$applicationDirectory${Platform.pathSeparator}logs'
        '${Platform.pathSeparator}dentallab.log',
      );

  final File _file;

  void info(String message) => _write('INFO', message);

  void warning(String message) => _write('WARN', message);

  void error(String message, Object error, StackTrace stackTrace) {
    _write('ERROR', '$message: $error\n$stackTrace', error, stackTrace);
  }

  void _write(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      message,
      name: 'DentalLab',
      error: error,
      stackTrace: stackTrace,
    );
    _file.parent.createSync(recursive: true);
    _file.writeAsStringSync(
      '[${DateTime.now().toUtc().toIso8601String()}] [$level] $message\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}
