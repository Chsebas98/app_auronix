import 'package:flutter/material.dart';

class LoadImageAsset extends StatelessWidget {
  const LoadImageAsset({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkIfAssetExists(context, imagePath),
      builder: (context, snapshot) {
        // Mientras se verifica la existencia del asset
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // Si el asset no existe, mostrar la imagen por defecto
        if (snapshot.hasData && snapshot.data == false) {
          return Image.asset(
            'assets/images/png/not_found_image.png',
            width: width,
            height: height,
            fit: fit,
          );
        }

        // Si existe, mostrar la imagen original
        return Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/png/not_found_image.png',
              width: width,
              height: height,
              fit: fit,
            );
          },
        );
      },
    );
  }

  Future<bool> _checkIfAssetExists(BuildContext context, String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
