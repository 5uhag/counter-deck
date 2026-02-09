import 'package:flutter/material.dart';

class SounDeckLogo extends StatelessWidget {
  final double size;

  const SounDeckLogo({Key? key, this.size = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF39FF14),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Top button (Yellow - waveform)
          Positioned(
            top: size * 0.1,
            left: size * 0.5 - size * 0.1,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.graphic_eq,
                size: size * 0.12,
                color: Colors.black,
              ),
            ),
          ),
          // Right button (Red - speaker)
          Positioned(
            top: size * 0.5 - size * 0.1,
            right: size * 0.1,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up,
                size: size * 0.12,
                color: Colors.white,
              ),
            ),
          ),
          // Bottom button (Blue - music note)
          Positioned(
            bottom: size * 0.1,
            left: size * 0.5 - size * 0.1,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.music_note,
                size: size * 0.12,
                color: Colors.white,
              ),
            ),
          ),
          // Left button (Green - play)
          Positioned(
            top: size * 0.5 - size * 0.1,
            left: size * 0.1,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                size: size * 0.12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
