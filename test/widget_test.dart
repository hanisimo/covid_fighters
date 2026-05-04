import 'package:flutter_test/flutter_test.dart';
import 'package:space_fighters/engine/game_status.dart';
import 'package:space_fighters/engine/game_widget.dart';
import 'package:space_fighters/main.dart';

void main() {
  testWidgets('Space Fighters starts and handles basic input', (
    WidgetTester tester,
  ) async {
    currentScreen = 0;

    await tester.pumpWidget(SpaceFightersGame());

    expect(find.byType(GameWidget), findsOneWidget);
    expect(tester.takeException(), isNull);

    final gameCenter = tester.getCenter(find.byType(GameWidget));

    await tester.tapAt(gameCenter);
    await tester.pump();

    expect(currentScreen, 1);
    expect(tester.takeException(), isNull);

    await tester.dragFrom(gameCenter, const Offset(24, 0));
    await tester.pump();

    await tester.tapAt(gameCenter);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
