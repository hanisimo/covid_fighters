import 'package:flutter/material.dart';

import 'package:covid19fighter/engine/game_render_engine.dart';

class WeaponBullet {
  var fighterHorizontalPosition, bulletVerticalPosition; // Bullet position (x,y)
  var gameOver = false; // is the game over?

  WeaponBullet(this.fighterHorizontalPosition);

  void paint(Canvas canvas, Size size) {
    if (gameOver) return;

    bulletVerticalPosition = bulletVerticalPosition ?? size.height - 60;

    if (bulletVerticalPosition < 0) {
      gameOver = true;
    } else {
      canvas.drawImageRect(sceneImage, Rect.fromLTWH(32, 0, 32, 32),
          Rect.fromLTWH(fighterHorizontalPosition, bulletVerticalPosition, elementSize, elementSize), scenePaint);

      bulletVerticalPosition -= 6;

      for (var enemy in enemyCharacters) {
        if (fighterHorizontalPosition >= enemy.x &&
            fighterHorizontalPosition <= enemy.x + elementSize &&
            bulletVerticalPosition >= enemy.y &&
            bulletVerticalPosition <= enemy.y + elementSize &&
            !enemy.killed) {
          this.gameOver = enemy.killed = true;
          currentScore += (size.height - bulletVerticalPosition).ceil();
          return;
        }
      }
    }
  }
}
