import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/button_config.dart';
import 'app_logger.dart';

class WebSocketService {
  final AppLogger _logger = AppLogger();
  WebSocketChannel? _channel;
  String _serverUrl = '';
  String _apiKey = '';
  bool _isConnected = false;
  final StreamController<List<ButtonConfig>> _configController =
      StreamController<List<ButtonConfig>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Stream<List<ButtonConfig>> get configStream => _configController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _isConnected;

  void connect(String host, int port, String apiKey) {
    _serverUrl = 'ws://$host:$port/ws';
    _apiKey = apiKey;
    _logger.info('Attempting connection to: $_serverUrl');
    _attemptConnection();
  }

  void _attemptConnection() async {
    try {
      _logger.debug('Creating WebSocket channel with API key...');
      // Add API key as query parameter
      final uri = Uri.parse('$_serverUrl?api_key=$_apiKey');
      _channel = WebSocketChannel.connect(uri);

      // Wait for connection to be ready before marking as connected
      await _channel!.ready;
      _isConnected = true;
      _connectionController.add(true);
      _logger.info('✓ WebSocket connected successfully');

      _channel!.stream.listen(
        (message) {
          _logger.debug(
              'Received message: ${message.toString().substring(0, message.toString().length > 100 ? 100 : message.toString().length)}...');
          _handleMessage(message);
        },
        onError: (error) {
          _logger.error('WebSocket error: $error');
          _isConnected = false;
          _connectionController.add(false);
          _errorController.add("Connection error: $error");
          _reconnect();
        },
        onDone: () {
          _logger.warning('WebSocket connection closed by server');
          _isConnected = false;
          _connectionController.add(false);
          _errorController.add("Connection closed by server");
          _reconnect();
        },
      );
    } catch (e) {
      _logger.error('Failed to connect: $e');
      _isConnected = false;
      _connectionController.add(false);
      _errorController.add("Connection failed: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    _logger.info('Reconnecting in 3 seconds...');
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isConnected && _serverUrl.isNotEmpty) {
        _logger.info('Initiating reconnection attempt');
        _attemptConnection();
      }
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      _logger.debug('Message type: ${data['type']}');
      if (data['type'] == 'config') {
        final buttons = (data['data']['buttons'] as List)
            .map((b) => ButtonConfig.fromJson(b))
            .toList();
        _logger.info('Received config with ${buttons.length} buttons');
        _configController.add(buttons);
      }
    } catch (e) {
      _logger.error('Error handling message: $e');
      print('Error handling message: $e');
    }
  }

  void sendButtonPress(int buttonId) {
    if (_isConnected && _channel != null) {
      _logger.debug('Sending button press: $buttonId');
      _channel!.sink.add(
        jsonEncode({'type': 'button_press', 'button_id': buttonId}),
      );
    } else {
      _logger.warning('Cannot send button press - not connected');
    }
  }

  void sendIconChangeRequest(int buttonId) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(
        jsonEncode({'type': 'icon_change_request', 'button_id': buttonId}),
      );
    }
  }

  void sendIconRemoveRequest(int buttonId) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(
        jsonEncode({'type': 'icon_remove_request', 'button_id': buttonId}),
      );
    }
  }

  void disconnect() {
    _logger.info('Disconnecting WebSocket');
    _isConnected = false;
    _connectionController.add(false);
    _channel?.sink.close();
  }

  void dispose() {
    disconnect();
    _configController.close();
    _connectionController.close();
    _errorController.close();
  }
}
