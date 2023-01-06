import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Color color;
  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.color),
        child: Image.file(
          File(imagePath),
        ),
      ),
    );
  }
}
