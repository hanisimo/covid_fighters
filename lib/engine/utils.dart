import 'dart:ui' as ui;

import 'package:flutter/services.dart';

// Load Graphics Assets
Future<ui.Image> loadGraphicsAssets() async {
  final ByteData graphicsAssets =
      await rootBundle.load('assets/graphics/graphics.png');
  final ui.Codec instantiateImageCodec =
      await ui.instantiateImageCodec(graphicsAssets.buffer.asUint8List());
  final ui.FrameInfo frameInfo = await instantiateImageCodec.getNextFrame();
  return frameInfo.image;
}
