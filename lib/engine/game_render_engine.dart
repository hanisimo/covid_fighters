import 'dart:math';

import 'package:covid19fighter/elements/enemy_character.dart';
import 'package:covid19fighter/elements/weapon_bullet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

import 'game_status.dart';
import 'utils.dart';

final double elementSize = 32.0; // Moving elements, characters & objects size

var sceneImage; // Scene Image represents the loaded Graphics Assets
Paint scenePaint =
    Paint(); // A description of the style to use when drawing on a Canvas

int currentScore = 0; // Current Score
int currentDifficultyLevel = 1; // Level Difficulty = Enemy Speed

late List<WeaponBullet> weaponBullets; // Weapon Bullets
late List<EnemyCharacter> enemyCharacters; // Enemy Characters

class GameRenderEngine extends RenderProxyBox {
  // Select a fighter character randomly (using a generator of random int values)
  final int currentFighterCharacter =
      Random().nextInt(3); // Current Fighter Character (Index)

  double? fighterHorizontalPosition; // Fighter X position (Location)
  late int frameCallbackId;

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
      // Start New Game
      currentScore = 0;
      currentDifficultyLevel = 1;
    } else {
      // Move to the next level
      currentDifficultyLevel++;
    }

    enemyCharacters = [];
    weaponBullets = [];

    // Add a new set of enemy characters
    for (var i = 0; i < (10 * currentDifficultyLevel); i++) {
      enemyCharacters
          .add(EnemyCharacter((i * -elementSize), constraints.biggest));
    }
  }

  // FrameCallback Timer
  void frameCallbackTimer(Duration duration) {
    if (attached) {
      scheduleTransientFrameCallback();
      markNeedsPaint();
    } else {
      return;
    }
  }

  @override
  void attach(PipelineOwner pipelineOwner) {
    super.attach(pipelineOwner);
    loadGraphicsAssets().then((loadedGraphicsAsset) {
      sceneImage = loadedGraphicsAsset;
      scheduleTransientFrameCallback();
    });
  }

  @override
  void detach() {
    super.detach();
    // Cancels the transient frame callback with the given id.
    SchedulerBinding.instance!.cancelFrameCallbackWithId(frameCallbackId);
  }

  // Schedule transient frame callback
  void scheduleTransientFrameCallback() => frameCallbackId =
      SchedulerBinding.instance!.scheduleFrameCallback(frameCallbackTimer);

  // Fire weapon bullet
  void fireWeaponBullet() =>
      weaponBullets.add(WeaponBullet(fighterHorizontalPosition));

  // Move fighter
  void moveFighter(double fighterPosition) =>
      this.fighterHorizontalPosition = fighterPosition;

  // Paint the current score
  void paintCurrentScore(Canvas canvas) {
    final numberFormatter = new intl.NumberFormat("###,###,###");

    TextSpan currentScoreTextSpan = new TextSpan(
        // Set the current Score text style
        style: new TextStyle(
            color: Colors.deepOrange,
            fontSize: 26.0,
            fontWeight: FontWeight.bold),
        // Set the current score
        text: "Score: ${numberFormatter.format(currentScore)}" +
            " - " +
            "Level: " +
            (currentDifficultyLevel).toString());

    // Create the current score the Text Painter
    TextPainter currentScoreTextPainter = new TextPainter(
        text: currentScoreTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    currentScoreTextPainter.layout();

    // Paint the current score
    currentScoreTextPainter.paint(canvas, new Offset(12.0, 16.0));
  }

  // Paint the game scene
  @override
  void paint(PaintingContext paintingContext, Offset offset) {
    if (sceneImage == null) return;

    paintingContext.setIsComplexHint();

    var paintingContextCanvas = paintingContext.canvas;
    var fighterVerticalPosition = size.height - 48;
    var renderBoxSize = size;

    // Check if we are at the "Game-intro" screen
    if (currentScreen == 0) {
      paintingContextCanvas.drawImageRect(
          sceneImage,
          Rect.fromLTWH(0, 32, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);
      return;
    } else if (currentScreen == 2) {
      // Check if the game is over?

      paintingContextCanvas.drawImageRect(
          sceneImage,
          Rect.fromLTWH(0, 992, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);
      paintCurrentScore(paintingContextCanvas);
      return;
    } else {
      // The game is active => we are at the "Game Mode"
      if (fighterHorizontalPosition == null)
        fighterHorizontalPosition = size.width / 2 - 16.0;

      if (fighterHorizontalPosition! < 0) fighterHorizontalPosition = 0;

      if (fighterHorizontalPosition! > renderBoxSize.width - elementSize)
        fighterHorizontalPosition = renderBoxSize.width - elementSize;

      // If all enemies are killed, move to the next level :)
      if (enemyCharacters.every((enemy) => enemy.killed)) startNewLevel();

      // Paint the game scene
      paintingContextCanvas.drawImageRect(
          sceneImage,
          Rect.fromLTWH(0, 1952, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);

      // Paint the fighter character
      paintingContextCanvas.drawImageRect(
          sceneImage,
          Rect.fromLTWH(64 + (currentFighterCharacter * 32.0), 0, elementSize,
              elementSize),
          Rect.fromLTWH(
              fighterHorizontalPosition!, fighterVerticalPosition, 32, 32),
          scenePaint);

      // Paint the current score
      paintCurrentScore(paintingContextCanvas);

      // Paint the enemies characters
      enemyCharacters.forEach((enemy) {
        enemy.paint(paintingContextCanvas);

        // Check if the game is over?
        if (!enemy.killed &&
            enemy.x! >= fighterHorizontalPosition! &&
            enemy.x! <= fighterHorizontalPosition! + elementSize &&
            enemy.y! + elementSize >= fighterVerticalPosition) {
          // Game over :(
          currentScreen = 2;
          return;
        }
      });

      // Paint the weapon bullets
      weaponBullets.forEach(
          (bullet) => bullet.paint(paintingContextCanvas, renderBoxSize));
    }
  }

  @override
  bool get isRepaintBoundary => true;
}
