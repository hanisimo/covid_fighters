import 'package:flutter/material.dart';
import 'package:space_fighters/elements/enemy_character.dart';
import 'package:space_fighters/engine/game_render_engine.dart';

class WeaponBullet {
  WeaponBullet(this.fighterHorizontalPosition);
  double? fighterHorizontalPosition; // Bullet X position (x,y)
  double? bulletVerticalPosition; // Bullet Y position (x,y)
  var gameOver = false;

  void update(Size size, List<EnemyCharacter> enemies) {
    if (gameOver) return;

    bulletVerticalPosition = bulletVerticalPosition ?? size.height - 60;

    if (bulletVerticalPosition! < 0) {
      gameOver = true;
    } else {
      bulletVerticalPosition = bulletVerticalPosition! - 6;

      for (var enemy in enemies) {
        if (!enemy.killed &&
            fighterHorizontalPosition! >= enemy.x! &&
            fighterHorizontalPosition! <= enemy.x! + elementSize &&
            bulletVerticalPosition! >= enemy.y! &&
            bulletVerticalPosition! <= enemy.y! + elementSize) {
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

  void paint(Canvas canvas, Size size) {
    if (gameOver) return;

    bulletVerticalPosition = bulletVerticalPosition ?? size.height - 60;

    canvas.drawImageRect(
        sceneImage!,
        const Rect.fromLTWH(32, 0, 32, 32),
        Rect.fromLTWH(fighterHorizontalPosition!, bulletVerticalPosition!,
            elementSize, elementSize),
        scenePaint);
  }
}
