import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  bool _isEnabled = false;
  File? _logFile;
  final List<String> _memoryLogs = [];
  static const int _maxMemoryLogs = 100;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('debug_logging') ?? false;

    if (_isEnabled) {
      await _initLogFile();
    }
  }

  Future<void> _initLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/SounDeck');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _logFile = File('${logDir.path}/app_log.txt');

      // Add header to new log session
      final timestamp = DateTime.now().toIso8601String();
      await _logFile!.writeAsString(
        '\n=== New Session Started at $timestamp ===\n',
        mode: FileMode.append,
      );
    } catch (e) {
      print('Failed to initialize log file: $e');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('debug_logging', enabled);

    if (enabled && _logFile == null) {
      await _initLogFile();
    }
  }

  bool get isEnabled => _isEnabled;

  void log(String message, {String level = 'INFO'}) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [$level] $message';

    // Always keep in memory logs (limited)
    _memoryLogs.add(logEntry);
    if (_memoryLogs.length > _maxMemoryLogs) {
      _memoryLogs.removeAt(0);
    }

    // Print to console
    print(logEntry);

    // Write to file if enabled (serialized writes)
    if (_isEnabled && _logFile != null) {
      try {
        await _logFile!.writeAsString('$logEntry\n', mode: FileMode.append);
      } catch (e) {
        print('Failed to write to log file: $e');
      }
    }
  }

  void debug(String message) => log(message, level: 'DEBUG');
  void info(String message) => log(message, level: 'INFO');
  void warning(String message) => log(message, level: 'WARN');
  void error(String message) => log(message, level: 'ERROR');

  List<String> getMemoryLogs() => List.from(_memoryLogs);

  Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }

  Future<void> clearLogs() async {
    _memoryLogs.clear();
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
      final timestamp = DateTime.now().toIso8601String();
      await _logFile!.writeAsString(
        '=== Logs Cleared at $timestamp ===\n',
        mode: FileMode.append,
      );
    }
  }
}
