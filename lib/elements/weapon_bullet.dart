import 'package:flutter/material.dart';
import 'package:space_fighters/elements/enemy_character.dart';
import 'package:space_fighters/engine/game_render_engine.dart';

class WeaponBullet {
  WeaponBullet(this.x);

  final double x; // Bullet X position
  double? y; // Bullet Y position
  bool gameOver = false;

  void update(Size size, List<EnemyCharacter> enemies) {
    if (gameOver) return;

    // Initialize or update vertical position
    y = (y ?? size.height - 60) - 6;

    if (y! < 0) {
      gameOver = true;
      return;
    }

    // Optimization: Create bullet Rect once per update
    final bulletRect = Rect.fromLTWH(x, y!, elementSize, elementSize);

    for (final enemy in enemies) {
      // Basic collision detection using Rect.overlaps
      if (!enemy.killed) {
        final enemyRect = Rect.fromLTWH(enemy.x, enemy.y!, elementSize, elementSize);
        if (bulletRect.overlaps(enemyRect)) {
          gameOver = enemy.killed = true;
          // Update the current score. 
          // Note: Simplified (size.height - (size.height - y)) to just y
          currentScore += y!.ceil() * currentDifficultyLevel;
          return;
        }
      }
    }
  }

  void paint(Canvas canvas, Size size) {
    if (gameOver || y == null) return;

    canvas.drawImageRect(
      sceneImage!,
      const Rect.fromLTWH(32, 0, 32, 32),
      Rect.fromLTWH(x, y!, elementSize, elementSize),
      scenePaint,
    );
  }
}
