import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'dart:math';

import 'package:covid19fighter/main.dart';
import 'package:covid19fighter/elements/enemy_character.dart';
import 'package:covid19fighter/elements/weapon_bullet.dart';
import 'package:covid19fighter/engine/utils.dart';

final double elementSize = 32.0; // Moving elements, characters & objects size

var sceneImage; // Scene Image represents the loaded Graphics Assets
Paint scenePaint =
    Paint(); // A description of the style to use when drawing on a Canvas

int currentScore = 0; // Current Score
int levelDifficulty = 2; // Level Difficulty = Enemy Speed

List<WeaponBullet> weaponBullets; // Weapon Bullets
List<EnemyCharacter> enemyCharacters; // Enemy Characters

class GameRenderEngine extends RenderBox {
  int currentFighterCharacter = 0; // Current Fighter Character (Index)
  Random randomNumber = Random(); // A generator of random int values
  double fighterHorizontalPosition; // Fighter X position (Location)
  int frameCallbackId;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    if (attached) startNewLevel();
  }

  // start a new level -> move to the next level
  void startNewLevel() {
    enemyCharacters = [];
    weaponBullets = [];
    levelDifficulty++;

    // Add a new set of enemy characters
    for (var i = 0; i < 10; i++) {
      enemyCharacters
          .add(EnemyCharacter((i * -elementSize), constraints.biggest));
    }
  }

  // Start New Game
  void startNewGame() {
    levelDifficulty = 2;
    currentFighterCharacter = randomNumber.nextInt(3);
    startNewLevel();
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
    SchedulerBinding.instance.cancelFrameCallbackWithId(frameCallbackId);
  }

  // Schedule transient frame callback
  void scheduleTransientFrameCallback() => frameCallbackId =
      SchedulerBinding.instance.scheduleFrameCallback(frameCallbackTimer);

  // Fire weapon bullet
  void fireWeaponBullet() => weaponBullets.add(WeaponBullet(fighterHorizontalPosition));

  // Move fighter
  void moveFighter(double fighterPosition) =>
      this.fighterHorizontalPosition = fighterPosition;

  void paintCurrentScore(Canvas canvas) {
    TextSpan currentScoreTextSpan = new TextSpan(
        style: new TextStyle(color: Colors.black, fontSize: 18.0),
        text: "Score $currentScore");
    TextPainter currentScoreTextPainter = new TextPainter(
        text: currentScoreTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    currentScoreTextPainter.layout();
    currentScoreTextPainter.paint(canvas, new Offset(12.0, 16.0));
  }

  @override
  void paint(PaintingContext paintingContext, Offset offset) {
    if (sceneImage == null) return;

    paintingContext.setIsComplexHint();

    var paintingContextCanvas = paintingContext.canvas;
    var fighterVerticalPosition = size.height - 48;
    var renderBoxSize = size;

    if (currentScreen == 0) {
      paintingContextCanvas.drawImageRect(
          sceneImage,
          Rect.fromLTWH(0, 32, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);
      return;
    }

    if (currentScreen == 2) {
      paintingContextCanvas.drawImageRect(
          sceneImage,
          Rect.fromLTWH(0, 992, 600.0, 960.0),
          Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
          scenePaint);
      paintCurrentScore(paintingContextCanvas);
      return;
    }

    if (fighterHorizontalPosition == null) fighterHorizontalPosition = size.width / 2 - 16.0;
    if (fighterHorizontalPosition < 0) fighterHorizontalPosition = 0;
    if (fighterHorizontalPosition > renderBoxSize.width - elementSize)
      fighterHorizontalPosition = renderBoxSize.width - elementSize;
    if (enemyCharacters.every((enemy) => enemy.killed)) startNewLevel();

    paintingContextCanvas.drawImageRect(
        sceneImage,
        Rect.fromLTWH(0, 1952, 600.0, 960.0),
        Rect.fromLTWH(0, 0, renderBoxSize.width, renderBoxSize.height),
        scenePaint);

    paintingContextCanvas.drawImageRect(
        sceneImage,
        Rect.fromLTWH(
            64 + (currentFighterCharacter * 32.0), 0, elementSize, elementSize),
        Rect.fromLTWH(fighterHorizontalPosition, fighterVerticalPosition, 32, 32),
        scenePaint);

    paintCurrentScore(paintingContextCanvas);

    enemyCharacters.forEach((enemy) {
      enemy.u(paintingContextCanvas);
      if (!enemy.killed &&
          enemy.x >= fighterHorizontalPosition &&
          enemy.x <= fighterHorizontalPosition + elementSize &&
          enemy.y + elementSize >= fighterVerticalPosition) {
        currentScreen = 2;
        startNewGame();
        return;
      }
    });

    weaponBullets.forEach((bullet) => bullet.paint(paintingContextCanvas, renderBoxSize));
  }

  @override
  bool get isRepaintBoundary => true;
}
