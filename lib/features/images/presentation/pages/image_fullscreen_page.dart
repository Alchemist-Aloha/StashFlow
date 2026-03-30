import 'package:flutter/material.dart';

class ImageFullscreenPage extends StatelessWidget {
  final String imageId;
  const ImageFullscreenPage({required this.imageId, super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Fullscreen Image')));
}
