import 'package:flutter/material.dart';
import 'package:space_fighters/engine/game_render_engine.dart';

class EnemyCharacter {
  EnemyCharacter(this.x);
  double? x; // Enemy X position (x, y)
  double? y; // Enemy Y position (x, y)
  bool moveToNextLine = false;
  bool killed = false;

  void update(int difficultyLevel, Size size) {
    if (killed) return;

    // Enemy Character vertical position
    y = y ?? (size.height % elementSize) + 32 + 16;

    if (!moveToNextLine) {
      x = x! + difficultyLevel;

      if (x! > size.width - elementSize) {
        moveToNextLine = true;
        x = size.width - elementSize;
        y = y! + elementSize;
      }
    } else {
      x = x! - difficultyLevel;

      if (x! < 0) {
        moveToNextLine = false;
        y = y! + elementSize;
      }
    }
  }

  void paint(Canvas canvas) {
    // Check if this enemy character is killed or alive?
    if (!killed) {
      // We paint only the alive enemy characters
      if (x! > 0) {
        canvas.drawImageRect(sceneImage!, const Rect.fromLTWH(0, 0, 32, 32),
            Rect.fromLTWH(x!, y!, elementSize, elementSize), scenePaint);
      }
    }
  }
}
