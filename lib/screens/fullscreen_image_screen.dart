import 'package:flutter/material.dart';
import 'package:safeen_institute/widgets/cached_image.dart';

class FullscreenImageScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullscreenImageScreen({
    super.key,
    required this.imageUrl,
    this.heroTag = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: heroTag.isNotEmpty
              ? Hero(
                  tag: heroTag,
                  child: CachedImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                )
              : CachedImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
