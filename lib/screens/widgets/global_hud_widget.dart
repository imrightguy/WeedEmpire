import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/game_state.dart';
import 'empire_widgets.dart';

class GlobalHudWidget extends StatelessWidget {
  const GlobalHudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Resource HUD
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: EmpireTheme.lightMetal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black54, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 4), blurRadius: 4),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHudItem('CASH', '\$${gameState.cash.toStringAsFixed(2)}', EmpireTheme.neonGreen),
              _buildHudItem('STASH', '${gameState.weedStash.toStringAsFixed(1)}g', Colors.white),
              if (gameState.streetCred > 0)
                _buildHudItem('CRED', '${gameState.streetCred}', EmpireTheme.brightOrange),
              if (gameState.goldBars > 0)
                _buildHudItem('BARS', '${gameState.goldBars}', const Color(0xFFFFD700)),
            ],
          ),
        ),

        // Active Event Banner
        if (gameState.activeEvent != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EmpireTheme.errorRed.withValues(alpha: 0.2),
              border: Border.all(color: EmpireTheme.errorRed, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: EmpireTheme.errorRed, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      gameState.activeEvent!.title,
                      style: GoogleFonts.bangers(fontSize: 24, color: EmpireTheme.errorRed, letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  gameState.activeEvent!.description,
                  textAlign: TextAlign.center,
                  style: EmpireTheme.bodyStyle,
                ),
                const SizedBox(height: 12),
                EmpireButton(
                  text: 'HIRE TRUTH TUBER (10 CRED)',
                  isPrimary: false,
                  icon: const Icon(Icons.campaign, color: Colors.white),
                  onPressed: gameState.streetCred >= 10 
                      ? () => context.read<GameState>().resolveEventWithCred()
                      : null,
                ),
              ],
            ),
          ),
        ],

        // Place the extra action overlay inside the HUD
        _buildExtraActionsLayer(context, gameState),
      ],
    );
  }

  // A floating overlay column to hold extra HUD actions like God Mode
  Widget _buildExtraActionsLayer(BuildContext context, GameState gameState) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
        child: Column(
          children: [
            FloatingActionButton.small(
              backgroundColor: gameState.isGodMode ? EmpireTheme.neonGreen : EmpireTheme.lightMetal,
              onPressed: () => context.read<GameState>().toggleGodMode(),
              child: Icon(
                gameState.isGodMode ? Icons.explore : Icons.person_pin_circle,
                color: gameState.isGodMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gameState.isGodMode ? 'PAN' : 'FOLLOW',
              style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
          ),
        ],
      ),
    );
  }
}
