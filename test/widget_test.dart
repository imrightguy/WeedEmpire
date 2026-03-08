import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:weed_empire/main.dart';
import 'package:weed_empire/state/game_state.dart';

void main() {
  testWidgets('App should build successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameState()),
        ],
        child: const WeedEmpireApp(),
      ),
    );

    // Verify it doesn't immediately crash.
    expect(find.text('Weed Empire Management'), findsOneWidget);
  });
}
