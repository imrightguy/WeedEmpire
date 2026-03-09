import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/game_state.dart';
import 'screens/main_screen.dart';
import 'game/weed_empire_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize monetization & platform services (Disabled for local testing)
  // AdService().initialize();
  // PlayGamesService().signIn();

  final gameState = GameState();
  // Fire and forget initialization. The UI will show defaults and update once loaded.
  gameState.initSaveData(); 

  final gameInstance = WeedEmpireGame(gameState: gameState);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameState),
      ],
      child: WeedEmpireApp(gameInstance: gameInstance),
    ),
  );
}

class WeedEmpireApp extends StatelessWidget {
  final WeedEmpireGame gameInstance;
  const WeedEmpireApp({super.key, required this.gameInstance});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weed Empire',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.oswaldTextTheme(ThemeData.dark().textTheme),
      ),
      home: MainScreen(gameInstance: gameInstance),
    );
  }
}
