// the Game main UI widget
import 'package:flutter/material.dart';

import 'package:space_fighters/engine/game_render_engine.dart';
import 'package:space_fighters/engine/game_status.dart';

class GameWidget extends SingleChildRenderObjectWidget {
  GameWidget({super.key});
  final GameRenderEngine gameRenderEngine = GameRenderEngine();

  @override
  RenderObject createRenderObject(BuildContext context) => gameRenderEngine;

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
      gameRenderEngine.startGameLoop();

      return;
    }
  }

  // Tap Handler
  void tapHandler() {
    // Are we at the Game-intro
    if (currentScreen == 0) {
      // we are at the Game-intro, So Start the game
      currentScreen = 1; // Start the game
      gameRenderEngine.startGameLoop();

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
