import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart' as rive;

class SafeRive extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final Widget? fallback;
  const SafeRive({super.key, required this.assetPath, this.fit = BoxFit.contain, this.fallback});

  Future<Uint8List?> _load() async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return fallback ?? const SizedBox.shrink();
        }
        final bytes = snapshot.data;
        if (bytes == null) {
          return fallback ?? const SizedBox.shrink();
        }
        final file = rive.RiveFile.import(bytes.buffer.asByteData());
        final artboard = file.mainArtboard;
        return rive.Rive(artboard: artboard, fit: fit);
      },
    );
  }
}