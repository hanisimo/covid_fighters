// the Game main UI widget
import 'package:flutter/material.dart';

import 'game_render_engine.dart';
import 'game_status.dart';

class GameWidget extends SingleChildRenderObjectWidget {
  final GameRenderEngine gameRenderEngine = GameRenderEngine();

  @override
  RenderObject createRenderObject(BuildContext buildContext) =>
      gameRenderEngine;

  // Swipe Handler
  void swipeHandler(double fighterPosition) {
    // Check if the Game is Not Over => Move the Fighter
    if (currentScreen == 1) {
      // Move Fighter
      gameRenderEngine.moveFighter(fighterPosition);
    } else if (currentScreen == 2) {
      // Game is Not Over
      currentScreen = 1;
      gameRenderEngine.startNewLevel(startNewGame: true);

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
      gameRenderEngine.fireWeaponBullet();

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
