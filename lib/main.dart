import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/game_state.dart';
import 'screens/responsive_layout.dart';
import 'screens/business_menu.dart';
import 'game/weed_empire_game.dart';
import 'services/ad_service.dart';
import 'services/play_games_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize monetization & platform services
  AdService().initialize();
  PlayGamesService().signIn();

  final gameState = GameState();
  // Fire and forget initialization. The UI will show defaults and update once loaded.
  gameState.initSaveData(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameState),
      ],
      child: const WeedEmpireApp(),
    ),
  );
}

class WeedEmpireApp extends StatelessWidget {
  const WeedEmpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weed Empire',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.oswaldTextTheme(ThemeData.dark().textTheme),
      ),
      home: Consumer<GameState>(
        builder: (context, gameState, child) {
          return ResponsiveLayout(
            // GameWorld embedded in Flutter widget tree
            gameArea: GameWidget(game: WeedEmpireGame(gameState: gameState)),
            menuArea: const BusinessMenu(),
          );
        },
      ),
    );
  }
}
