import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/button_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  String _serverUrl = '';
  bool _isConnected = false;
  final StreamController<List<ButtonConfig>> _configController =
      StreamController<List<ButtonConfig>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<List<ButtonConfig>> get configStream => _configController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  void connect(String host, int port) {
    _serverUrl = 'ws://$host:$port/ws';
    _attemptConnection();
  }

  void _attemptConnection() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      _isConnected = true;
      _connectionController.add(true);

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          _isConnected = false;
          _connectionController.add(false);
          _reconnect();
        },
        onDone: () {
          _isConnected = false;
          _connectionController.add(false);
          _reconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      _connectionController.add(false);
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isConnected && _serverUrl.isNotEmpty) {
        _attemptConnection();
      }
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'config') {
        final buttons = (data['data']['buttons'] as List)
            .map((b) => ButtonConfig.fromJson(b))
            .toList();
        _configController.add(buttons);
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void sendButtonPress(int buttonId) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(
        jsonEncode({'type': 'button_press', 'button_id': buttonId}),
      );
    }
  }

  void disconnect() {
    _isConnected = false;
    _channel?.sink.close();
  }

  void dispose() {
    disconnect();
    _configController.close();
    _connectionController.close();
  }
}
