import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  DateTime _lastScanAttempt =
      DateTime.now().subtract(const Duration(seconds: 10));

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String rawValue) async {
    if (_isProcessing) return;

    // Debounce - only process if 3 seconds have passed since last attempt
    final now = DateTime.now();
    if (now.difference(_lastScanAttempt).inSeconds < 3) {
      return;
    }
    _lastScanAttempt = now;

    setState(() => _isProcessing = true);

    try {
      // Parse JSON from QR code
      final data = jsonDecode(rawValue);

      final String ip = data['ip'] ?? '';
      final int port = data['port'] ?? 8000;
      final String apiKey = data['api_key'] ?? '';

      if (ip.isEmpty || apiKey.isEmpty) {
        throw Exception('Invalid QR code data');
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('host', ip);
      await prefs.setInt('port', port);
      await prefs.setString('api_key', apiKey);

      if (mounted) {
        // Show success and return
        Navigator.pop(context, {
          'host': ip,
          'port': port,
          'api_key': apiKey,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ QR Code scanned successfully!'),
            backgroundColor: Color(0xFF39FF14),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Invalid QR code'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Color(0xFF39FF14)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF39FF14)),
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Overlay with instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF39FF14),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Point camera at the QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The QR code is displayed in the SounDeck GUI',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit, color: Color(0xFF39FF14)),
                    label: const Text('Enter Manually'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF39FF14),
                      side: const BorderSide(color: Color(0xFF39FF14)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
