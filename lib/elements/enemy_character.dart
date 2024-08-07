import 'package:flutter/material.dart';
import 'package:space_fighters/engine/game_render_engine.dart';

class EnemyCharacter {
  double? x; // Enemy X position (x, y)
  double? y; // Enemy Y position (x, y)
  bool moveToNextLine = false;
  Size characterSize;
  bool killed = false; // is this enemy already killed?

  EnemyCharacter(this.x, this.characterSize);

  void paint(Canvas canvas) {
    // Check if this enemy character is killed or alive?
    if (!killed) {
      // Enemy Character vertical position
      y = y ?? (characterSize.height % elementSize) + 32 + 16;

      // We paint only the alive enemy characters
      if (x! > 0) {
        canvas.drawImageRect(sceneImage!, const Rect.fromLTWH(0, 0, 32, 32),
            Rect.fromLTWH(x!, y!, elementSize, elementSize), scenePaint);
      }
      if (!moveToNextLine) {
        x = x! + currentDifficultyLevel;

        if (x! > characterSize.width - elementSize) {
          moveToNextLine = true;
          x = characterSize.width - elementSize;
          y = y! + elementSize;
        }
      } else {
        x = x! - currentDifficultyLevel;

        if (x! < 0) {
          moveToNextLine = false;
          y = y! + elementSize;
        }
      }
    }
  }
}
