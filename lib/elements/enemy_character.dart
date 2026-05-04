import 'package:flutter/material.dart';
import 'package:space_fighters/engine/game_render_engine.dart';

class EnemyCharacter {
  EnemyCharacter(this.x);

  double x; // Enemy X position
  double? y; // Enemy Y position
  bool moveToNextLine = false;
  bool killed = false;

  void update(int difficultyLevel, Size size) {
    if (killed) return;

    // Enemy Character vertical position initialization
    y ??= (size.height % elementSize) + 48; // 32 + 16 = 48

    if (!moveToNextLine) {
      x += difficultyLevel;

      if (x > size.width - elementSize) {
        moveToNextLine = true;
        x = size.width - elementSize;
        y = y! + elementSize;
      }
    } else {
      x -= difficultyLevel;

      if (x < 0) {
        moveToNextLine = false;
        y = y! + elementSize;
      }
    }
  }

  void paint(Canvas canvas) {
    if (killed || y == null) return;

    // Only paint if the character is likely visible
    if (x + elementSize > 0) {
      canvas.drawImageRect(
        sceneImage!,
        const Rect.fromLTWH(0, 0, 32, 32),
        Rect.fromLTWH(x, y!, elementSize, elementSize),
        scenePaint,
      );
    }
  }
}
