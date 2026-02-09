import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/button_config.dart';
import '../services/websocket_service.dart';
import '../widgets/sound_button.dart';
import '../widgets/soundeck_logo.dart';
import 'browser_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  List<ButtonConfig> _buttons = [];
  bool _isConnected = false;
  String _host = '192.168.1.100';
  int _port = 8000;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _host = prefs.getString('host') ?? '10.0.2.2';
      _port = prefs.getInt('port') ?? 8000;
    });
    _webSocketService.connect(_host, _port);
  }

  void _setupListeners() {
    _webSocketService.configStream.listen((buttons) {
      setState(() {
        _buttons = buttons;
      });
    });

    _webSocketService.connectionStream.listen((connected) {
      setState(() {
        _isConnected = connected;
      });

      // Show connection status message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  connected ? Icons.check_circle : Icons.error,
                  color: connected ? const Color(0xFF39FF14) : Colors.red,
                ),
                const SizedBox(width: 12),
                Text(
                  connected
                      ? 'Connected to backend!'
                      : 'Disconnected from backend',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor:
                connected ? Colors.green.shade900 : Colors.red.shade900,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _onSettingsSaved(String host, int port) {
    setState(() {
      _host = host;
      _port = port;
    });
    _webSocketService.disconnect();
    _webSocketService.connect(host, port);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Initialize default buttons if empty
    if (_buttons.isEmpty) {
      _buttons = List.generate(
        24,
        (index) => ButtonConfig(
          id: index + 1, // IDs should be 1-24 to match backend config
          name: 'Button ${index + 1}',
          key: '',
          sound: '',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            const SounDeckLogo(size: 36),
            const SizedBox(width: 12),
            const Text(
              'SounDeck',
              style: TextStyle(color: Color(0xFF39FF14)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isConnected
                    ? const Color(0xFF39FF14).withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isConnected ? const Color(0xFF39FF14) : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color:
                          _isConnected ? const Color(0xFF39FF14) : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                    style: TextStyle(
                      color:
                          _isConnected ? const Color(0xFF39FF14) : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF39FF14)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrowserScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF39FF14)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onSettingsSaved: _onSettingsSaved,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mic Toggle Tiles
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '💡 Set CS2 mic to: CABLE Output (Virtual Cable)'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade900,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.graphic_eq,
                              color: Colors.purple, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'VB-CABLE',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sounds Mode',
                            style: TextStyle(
                              color: Colors.purple.shade300,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('💡 Set CS2 mic to: Your Real Microphone'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.mic, color: Colors.blue, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'REAL MIC',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Voice Mode',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Button Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  return SoundButton(
                    config: _buttons[index],
                    webSocketService: _webSocketService,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
