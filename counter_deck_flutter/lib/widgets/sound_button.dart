import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/button_config.dart';
import '../services/websocket_service.dart';

class SoundButton extends StatefulWidget {
  final ButtonConfig config;
  final WebSocketService webSocketService;
  final Function(ButtonConfig) onIconUpdated;

  const SoundButton({
    Key? key,
    required this.config,
    required this.webSocketService,
    required this.onIconUpdated,
  }) : super(key: key);

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Save image to app directory
        final directory = await getApplicationDocumentsDirectory();
        final iconPath =
            '${directory.path}/icons/button_${widget.config.id}.png';

        // Create icons directory if it doesn't exist
        final iconsDir = Directory('${directory.path}/icons');
        if (!await iconsDir.exists()) {
          await iconsDir.create(recursive: true);
        }

        // Copy image
        await File(image.path).copy(iconPath);

        // Update config
        widget.config.icon = iconPath;
        widget.onIconUpdated(widget.config);

        setState(() {});
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSound = widget.config.sound.isNotEmpty;
    final hasIcon =
        widget.config.icon.isNotEmpty && File(widget.config.icon).existsSync();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: hasSound
            ? () => widget.webSocketService.sendButtonPress(widget.config.id)
            : null,
        onLongPress: _pickImage,
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
                  child: Image.file(
                    File(widget.config.icon),
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
