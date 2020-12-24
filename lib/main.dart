import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'engine/game_render_engine.dart';

int currentScreen = 0; // Current Screen (Index),
/*
 current screen values:
    0 => Game-intro
    1 => Game is Active (Game Mode)
    2 => Game is Over
 */

void main() {
  // Binding to be initialized before calling runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Set the preferred orientation to portraitUp
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Run COVID-19 Fighter Game
  runApp(COVID19FighterGame());
}

// the App level UI widget
class COVID19FighterGame extends StatelessWidget {
  // This widget is the game root.
  final GameWidget gameWidget = GameWidget();

  @override
  Widget build(BuildContext buildContext) => MediaQuery(
        data: MediaQueryData.fromWindow(ui.window),
        child: Container(
          color: Colors.cyan[400],
          child: SafeArea(
            child: GestureDetector(
                onTap: () => gameWidget.tapHandler(),
                onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails) =>
                    gameWidget
                        .swipeHandler(dragUpdateDetails.globalPosition.dx),
                behavior: HitTestBehavior.translucent,
                child: gameWidget),
          ),
        ),
      );
}

// the Game main UI widget
class GameWidget extends SingleChildRenderObjectWidget {
  final GameRenderEngine gameRenderBox = GameRenderEngine();

  @override
  RenderObject createRenderObject(BuildContext buildContext) => gameRenderBox;

  // Swipe Handler
  void swipeHandler(double fighterPosition) {
    // Check if the Game is Not Over => Move the Fighter
    if (currentScreen == 1) {
      // Move Fighter
      gameRenderBox.moveFighter(fighterPosition);
    } else if (currentScreen == 2) {
      // Game is Not Over
      currentScreen = 1;
      gameRenderBox.startNewLevel(startNewGame: true);

      return;
    }
  }

  // Tap Handler
  void tapHandler() {
    // Are we at the Game-intro
    if (currentScreen == 0) {
      // we are at the Game-intro, So Start the game
      currentScreen = 1; // Start the game

      return;
    } else if (currentScreen == 1) {
      // Enjoy the game :")

      // Fire Weapon Bullet
      gameRenderBox.fireWeaponBullet();

      // Pay 10 score points for each bullet
      if ((currentScore - 10) > 0) {
        currentScore = currentScore - 10;
      } else {
        currentScore = 0;
      }

      return;
    } else if (currentScreen == 2) {
      // Game is Over :-( Sorry

      return;
    } else {
      // This "else" is for a future use ;)
      return;
    }
  }
}
