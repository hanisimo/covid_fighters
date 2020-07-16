import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

// Load Graphics Assets
Future<ui.Image> loadGraphicsAssets() async {
  ByteData graphicsAssets = await rootBundle.load("assets/graphics/graphics.png");
  ui.Codec instantiateImageCodec =
  await ui.instantiateImageCodec(graphicsAssets.buffer.asUint8List());
  ui.FrameInfo frameInfo = await instantiateImageCodec.getNextFrame();
  return frameInfo.image;
}