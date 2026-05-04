import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:space_fighters/engine/game_widget.dart';

void main() {
  // Binding to be initialized before calling runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Set the preferred orientation to portraitUp
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Run Space Fighters Game
  runApp(SpaceFightersGame());
}

// the App level UI widget
class SpaceFightersGame extends StatelessWidget {

  SpaceFightersGame({super.key});
  // This widget is the game root.
  final GameWidget gameWidget = GameWidget();

  @override
  Widget build(BuildContext context) => MediaQuery(
        data: MediaQueryData.fromView(View.of(context)),
        child: SafeArea(
          child: Container(
            color: Colors.cyan[400],
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
