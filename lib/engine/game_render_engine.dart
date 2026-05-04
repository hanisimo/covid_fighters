import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart' as intl;
import 'package:space_fighters/elements/enemy_character.dart';
import 'package:space_fighters/elements/weapon_bullet.dart';

import 'package:space_fighters/engine/game_status.dart';
import 'package:space_fighters/engine/utils.dart';

const double elementSize = 32.0; // Moving elements, characters & objects size

ui.Image? sceneImage; // Scene Image represents the loaded Graphics Assets
final Paint scenePaint = Paint()
  ..filterQuality = ui.FilterQuality.low; // Optimization for pixel-art assets

int currentScore = 0; // Current Score
int currentDifficultyLevel = 1; // Level Difficulty = Enemy Speed

late List<WeaponBullet> weaponBullets; // Weapon Bullets
late List<EnemyCharacter> enemyCharacters; // Enemy Characters

class GameRenderEngine extends RenderProxyBox {
  // Select a fighter character randomly
  final int currentFighterCharacter = Random().nextInt(3);

  double? fighterHorizontalPosition;
  int? frameCallbackId;

  // Caching for Text Rendering Optimization
  TextPainter? _scorePainter;
  int _lastScore = -1;
  int _lastLevel = -1;
  final _numberFormatter = intl.NumberFormat('###,###,###');

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    if (attached) startNewLevel(startNewGame: true);
  }

  // start a new level
  void startNewLevel({bool startNewGame = false}) {
    if (startNewGame) {
      currentScore = 0;
      currentDifficultyLevel = 1;
    } else {
      currentDifficultyLevel++;
    }

    enemyCharacters = [];
    weaponBullets = [];

    // Add a new set of enemy characters
    for (var i = 0; i < (10 * currentDifficultyLevel); i++) {
      enemyCharacters.add(EnemyCharacter((i * -elementSize)));
    }
  }

  // FrameCallback Timer
  void frameCallbackTimer(Duration duration) {
    if (!attached) return;

    // Only update and repaint if the game is active
    if (currentScreen == 1) {
      _updateGameLogic();
      markNeedsPaint();
    } else if (currentScreen == 0 || currentScreen == 2) {
      // Repaint for intro/outro screens, but don't run game logic
      markNeedsPaint();
    }

    scheduleTransientFrameCallback();
  }

  void _updateGameLogic() {
    final renderBoxSize = size;
    final fighterVerticalPosition = size.height - 48;

    fighterHorizontalPosition ??= size.width / 2 - 16.0;

    if (fighterHorizontalPosition! < 0) fighterHorizontalPosition = 0;

    if (fighterHorizontalPosition! > renderBoxSize.width - elementSize) {
      fighterHorizontalPosition = renderBoxSize.width - elementSize;
    }

    // Update enemies
    bool allKilled = true;
    for (var enemy in enemyCharacters) {
      if (!enemy.killed) {
        allKilled = false;
        enemy.update(currentDifficultyLevel, renderBoxSize);

        // Check if the game is over? (Collision with fighter)
        if (enemy.x! >= fighterHorizontalPosition! &&
            enemy.x! <= fighterHorizontalPosition! + elementSize &&
            enemy.y! + elementSize >= fighterVerticalPosition) {
          // Game over :(
          currentScreen = 2;
          return;
        }
      }
    }

    if (allKilled) {
      startNewLevel();
      return;
    }

    // Update weapon bullets and prune inactive ones
    weaponBullets.removeWhere((bullet) => bullet.gameOver);
    
    // We only check collisions against alive enemies
    final aliveEnemies = enemyCharacters.where((e) => !e.killed).toList();
    for (var bullet in weaponBullets) {
      bullet.update(renderBoxSize, aliveEnemies);
    }
    
    // Prune dead enemies from the main list to optimize next frame's iterations
    enemyCharacters.removeWhere((enemy) => enemy.killed);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (sceneImage == null) {
      loadGraphicsAssets().then((loadedGraphicsAsset) {
        sceneImage = loadedGraphicsAsset;
        markNeedsPaint();
      });
    }
    scheduleTransientFrameCallback();
  }

  @override
  void detach() {
    if (frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(frameCallbackId!);
      frameCallbackId = null;
    }
    super.detach();
  }

  // Schedule transient frame callback
  void scheduleTransientFrameCallback() =>
      frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(frameCallbackTimer);

  // Fire weapon bullet
  void fireWeaponBullet() =>
      weaponBullets.add(WeaponBullet(fighterHorizontalPosition!));

  // Move fighter
  void moveFighter(double fighterPosition) =>
      fighterHorizontalPosition = fighterPosition;

  // Paint the current score with layout caching
  void paintCurrentScore(Canvas canvas) {
    if (_scorePainter == null || _lastScore != currentScore || _lastLevel != currentDifficultyLevel) {
      _lastScore = currentScore;
      _lastLevel = currentDifficultyLevel;

      _scorePainter = TextPainter(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.deepOrange,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
          ),
          text: 'Score: ${_numberFormatter.format(currentScore)} - Level: $currentDifficultyLevel',
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      )..layout();
    }

    _scorePainter!.paint(canvas, const Offset(12.0, 16.0));
  }

  // Paint the game scene
  @override
  void paint(PaintingContext context, Offset offset) {
    if (sceneImage == null) return;

    final canvas = context.canvas;
    final renderBoxSize = size;
    final fighterVerticalPosition = size.height - 48;

    // Check screen state
    if (currentScreen == 0) {
      // Intro Screen
      canvas.drawImageRect(
          sceneImage!,
          const Rect.fromLTWH(0, 32, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);
    } else if (currentScreen == 2) {
      // Game Over Screen
      canvas.drawImageRect(
          sceneImage!,
          const Rect.fromLTWH(0, 992, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);
      paintCurrentScore(canvas);
    } else {
      // Game Active
      // Background
      canvas.drawImageRect(
          sceneImage!,
          const Rect.fromLTWH(0, 1952, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);

      // Fighter
      canvas.drawImageRect(
          sceneImage!,
          Rect.fromLTWH(64 + (currentFighterCharacter * 32.0), 0, elementSize,
              elementSize),
          Rect.fromLTWH(
              fighterHorizontalPosition!, fighterVerticalPosition, 32, 32),
          scenePaint);

      paintCurrentScore(canvas);

      // Enemies
      for (var enemy in enemyCharacters) {
        enemy.paint(canvas);
      }

      // Bullets
      for (var bullet in weaponBullets) {
        bullet.paint(canvas, renderBoxSize);
      }
    }
  }

  @override
  bool get isRepaintBoundary => true;
}
