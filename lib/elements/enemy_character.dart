import 'package:flutter/material.dart';
import 'package:covid19fighter/engine/game_render_engine.dart';

class EnemyCharacter {
  double x, y; // Enemy position (x, y)
  bool moveToNextLine = false;
  Size characterSize;
  bool killed = false; // is the game over?

  EnemyCharacter(this.x, this.characterSize);

  void u(Canvas canvas) {
    y = y ?? (characterSize.height % elementSize) + 16;

    if (!killed) {
      if (x > 0) {
        canvas.drawImageRect(sceneImage, Rect.fromLTWH(0, 0, 32, 32),
            Rect.fromLTWH(x, y, elementSize, elementSize), scenePaint);
      }
      if (!moveToNextLine) {
        x += levelDifficulty;

        if (x > characterSize.width - elementSize) {
          moveToNextLine = true;
          x = characterSize.width - elementSize;
          y += elementSize;
        }
      } else {
        x -= levelDifficulty;

        if (x < 0) {
          moveToNextLine = false;
          y += elementSize;
        }
      }
    }
  }
}
