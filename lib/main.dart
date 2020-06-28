import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import 'engine/game_render_engine.dart';

int currentScreen = 0; // Current Screen (Index)

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
                onTap: () => gameWidget.fireWeaponBullet(),
                onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails) =>
                    gameWidget.moveFighter(dragUpdateDetails.globalPosition.dx),
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
  RenderObject createRenderObject(BuildContext buildContext) =>
      gameRenderBox;

  // Move Fighter
  void moveFighter(double fighterPosition) {
    // Check if the Game is Over
    if (currentScreen == 2) {
      currentScore = 0; // Reset score
      currentScreen = 1; //Start the game
      return;
    } else {
      // Move Fighter
      gameRenderBox.moveFighter(fighterPosition);
    }
  }

  // Fire a bullet
  void fireWeaponBullet() {
    if (currentScreen == 0) {
      currentScreen = 1; //Start the game
    } else {
      // Fire Weapon Bullet
      gameRenderBox.fireWeaponBullet();
    }
  }
}
