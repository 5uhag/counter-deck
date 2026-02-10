import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/button_config.dart';
import '../services/websocket_service.dart';

class SoundButton extends StatefulWidget {
  final ButtonConfig config;
  final WebSocketService webSocketService;

  const SoundButton({
    Key? key,
    required this.config,
    required this.webSocketService,
  }) : super(key: key);

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  Uint8List? _iconBytes;

  @override
  void initState() {
    super.initState();
    _loadIcon();
  }

  @override
  void didUpdateWidget(SoundButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.icon != widget.config.icon) {
      _loadIcon();
    }
  }

  void _loadIcon() {
    if (widget.config.icon.isNotEmpty) {
      try {
        _iconBytes = base64Decode(widget.config.icon);
        if (mounted) setState(() {});
      } catch (e) {
        _iconBytes = null;
      }
    } else {
      _iconBytes = null;
    }
  }

  void _showIconMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFF39FF14)),
              title: const Text(
                'Change Icon',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.webSocketService.sendIconChangeRequest(widget.config.id);
              },
            ),
            if (widget.config.icon.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Icon',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.webSocketService
                      .sendIconRemoveRequest(widget.config.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleButtonPress() {
    if (!widget.webSocketService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Not connected to backend!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Color(0xFF661111),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    widget.webSocketService.sendButtonPress(widget.config.id);
  }

  @override
  Widget build(BuildContext context) {
    final hasSound = widget.config.sound.isNotEmpty;
    final hasIcon = _iconBytes != null;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: hasSound ? _handleButtonPress : null,
        onLongPress: _showIconMenu,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: hasSound ? const Color(0xFF39FF14) : Colors.grey.shade800,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: hasIcon
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    _iconBytes!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Text(
                    widget.config.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: hasSound ? const Color(0xFF39FF14) : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
