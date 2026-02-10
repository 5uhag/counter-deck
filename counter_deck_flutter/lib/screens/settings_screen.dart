import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_logger.dart';
import 'qr_scanner_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String, int) onSettingsSaved;

  const SettingsScreen({Key? key, required this.onSettingsSaved})
      : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final AppLogger _logger = AppLogger();
  bool _debugLoggingEnabled = false;
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hostController.text = prefs.getString('host') ?? '10.0.2.2';
      _portController.text = prefs.getInt('port')?.toString() ?? '8000';
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _debugLoggingEnabled = prefs.getBool('debug_logging') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    // Validate API key is not empty
    if (_apiKeyController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'API Key is required! Get it from the desktop GUI.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('host', _hostController.text);
    await prefs.setInt('port', int.tryParse(_portController.text) ?? 8000);
    await prefs.setString('api_key', _apiKeyController.text);

    widget.onSettingsSaved(
      _hostController.text,
      int.tryParse(_portController.text) ?? 8000,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved! Reconnecting...'),
          backgroundColor: Color(0xFF39FF14),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        _hostController.text = result['host'] ?? '';
        _portController.text = result['port']?.toString() ?? '8000';
        _apiKeyController.text = result['api_key'] ?? '';
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF39FF14)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend Connection',
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // QR Scanner Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39FF14),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _scanQRCode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '— OR —',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hostController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Host IP Address',
                labelStyle: const TextStyle(color: Color(0xFF39FF14)),
                hintText: '192.168.1.100',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF39FF14),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Port',
                labelStyle: const TextStyle(color: Color(0xFF39FF14)),
                hintText: '8000',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF39FF14),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: !_showApiKey,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'API Key (Required)',
                labelStyle: const TextStyle(color: Color(0xFF39FF14)),
                hintText: 'Get from desktop GUI',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF39FF14),
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showApiKey ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF39FF14),
                  ),
                  onPressed: () {
                    setState(() {
                      _showApiKey = !_showApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39FF14),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveSettings,
                child: const Text(
                  'Save & Connect',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF39FF14)),
            const SizedBox(height: 16),
            const Text(
              'Instructions:',
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ DON\'T use "localhost" - it won\'t work on Android!\n'
                      'Use your PC\'s IP address instead (like 192.168.x.x)',
                      style: TextStyle(
                        color: Colors.orange.shade200,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '1. Run the SounDeck GUI on your PC (soundeck_config.bat)\n'
              '2. Click "Start Backend" in the GUI\n'
              '3. Copy the API Key from the GUI (click Copy button)\n'
              '4. Find your PC\'s local IP:\n'
              '   • Shown in the GUI\n'
              '   • Windows: Run "ipconfig" in cmd\n'
              '   • Look for "IPv4 Address" (like 192.168.x.x)\n'
              '   • Android Emulator: Use 10.0.2.2\n'
              '5. Enter IP, Port, and API Key above\n'
              '6. Tap Save & Connect\n'
              '\n'
              '💡 TIP: Use the QR scanner for quick setup!',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF39FF14)),
            const SizedBox(height: 16),
            const Text(
              'Debug Logging',
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _debugLoggingEnabled,
              onChanged: (value) async {
                setState(() => _debugLoggingEnabled = value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('debug_logging', value);
                await _logger.setEnabled(value);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Debug logging enabled'
                            : 'Debug logging disabled',
                      ),
                      backgroundColor: const Color(0xFF39FF14),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              title: const Text(
                'Enable Debug Logs',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _debugLoggingEnabled
                    ? 'Logs are being saved to file'
                    : 'Enable to debug connection issues',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              activeColor: const Color(0xFF39FF14),
              tileColor: Colors.grey.shade900,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.article, color: Color(0xFF39FF14)),
                    label: const Text('View Logs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF39FF14),
                      side: const BorderSide(color: Color(0xFF39FF14)),
                    ),
                    onPressed: _viewLogs,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Clear Logs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: _clearLogs,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewLogs() {
    final logs = _logger.getMemoryLogs();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Debug Logs (Last 100)',
          style: TextStyle(color: Color(0xFF39FF14)),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: logs.isEmpty
              ? const Text(
                  'No logs yet. Logs will appear here once you connect.',
                  style: TextStyle(color: Colors.white),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    Color logColor = Colors.white;
                    if (log.contains('[ERROR]')) {
                      logColor = Colors.red;
                    } else if (log.contains('[WARN]')) {
                      logColor = Colors.orange;
                    } else if (log.contains('[INFO]')) {
                      logColor = const Color(0xFF39FF14);
                    } else if (log.contains('[DEBUG]')) {
                      logColor = Colors.grey.shade400;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        log,
                        style: TextStyle(color: logColor, fontSize: 10),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF39FF14)),
            ),
          ),
        ],
      ),
    );
  }

  void _clearLogs() async {
    await _logger.clearLogs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs cleared'),
          backgroundColor: Color(0xFF39FF14),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}
