import 'package:flutter/material.dart';
import 'package:space_fighters/engine/game_render_engine.dart';

class WeaponBullet {
  double? fighterHorizontalPosition; // Bullet X position (x,y)
  double? bulletVerticalPosition; // Bullet Y position (x,y)
  var gameOver = false; // is the game over?

  WeaponBullet(this.fighterHorizontalPosition);

  void paint(Canvas canvas, Size size) {
    if (gameOver) return;

    bulletVerticalPosition = bulletVerticalPosition ?? size.height - 60;

    if (bulletVerticalPosition! < 0) {
      gameOver = true;
    } else {
      canvas.drawImageRect(
          sceneImage!,
          const Rect.fromLTWH(32, 0, 32, 32),
          Rect.fromLTWH(fighterHorizontalPosition!, bulletVerticalPosition!,
              elementSize, elementSize),
          scenePaint);

      bulletVerticalPosition = bulletVerticalPosition! - 6;

      for (var enemy in enemyCharacters) {
        if (fighterHorizontalPosition! >= enemy.x! &&
            fighterHorizontalPosition! <= enemy.x! + elementSize &&
            bulletVerticalPosition! >= enemy.y! &&
            bulletVerticalPosition! <= enemy.y! + elementSize &&
            !enemy.killed) {
          gameOver = enemy.killed = true;
          // Update the current score depending on: the enemy position * the game level
          currentScore +=
              (size.height - (size.height - bulletVerticalPosition!)).ceil() *
                  currentDifficultyLevel;
          return;
        }
      }
    }
  }
}
