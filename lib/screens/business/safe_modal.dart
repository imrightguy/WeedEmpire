import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/game_state.dart';
import '../widgets/empire_widgets.dart';

class SafeModal extends StatelessWidget {
  const SafeModal({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Container(
      color: EmpireTheme.darkMetal,
      padding: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Google Play Games
            EmpireCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(children: [
                      const Icon(Icons.sports_esports, color: EmpireTheme.neonGreen, size: 24),
                      const SizedBox(width: 8),
                      Text('GOOGLE PLAY GAMES', style: GoogleFonts.bangers(fontSize: 20, color: Colors.white, letterSpacing: 1)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: EmpireButton(text: 'ACHIEVEMENTS', onPressed: () => showEmpireSnackbar(context, 'Disabled for local testing.', color: EmpireTheme.errorRed))),
                      const SizedBox(width: 8),
                      Expanded(child: EmpireButton(text: 'LEADERBOARD', isPrimary: false, onPressed: () => showEmpireSnackbar(context, 'Disabled for local testing.', color: EmpireTheme.errorRed))),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Employee Gacha
            Text('THE GACHA SAFE', style: EmpireTheme.headerStyle),
            const Text('Crack safes to hire new cartel employees!', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const Divider(color: Colors.white24, thickness: 1),
            EmpireCard(
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                    children: [
                       const Icon(Icons.lock, size: 48, color: EmpireTheme.neonGreen),
                       const SizedBox(height: 8),
                       EmpireButton(
                          text: 'BASIC SAFE (\$1,000)',
                          isPrimary: gameState.cash >= 1000,
                          onPressed: gameState.cash >= 1000 ? () => context.read<GameState>().rollEmployee(1000) : null,
                       ),
                       const SizedBox(height: 8),
                       EmpireButton(
                          text: 'GOLDEN SAFE (500 BARS)',
                          isPrimary: gameState.goldBars >= 500,
                          icon: const Icon(Icons.star, color: EmpireTheme.brightOrange, size: 18),
                          onPressed: gameState.goldBars >= 500 ? () => context.read<GameState>().rollGoldenSafe(500) : null,
                       ),
                       const SizedBox(height: 4),
                       const Text('Guaranteed Epic or Legendary!', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    ]
                 )
               )
            ),
            const SizedBox(height: 16),

            // Rewarded Ads
            Text('FREE REWARDS', style: EmpireTheme.headerStyle),
            const Divider(color: Colors.white24, thickness: 1),
            EmpireCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  EmpireButton(
                    text: 'MIRACLE GROW (5x SPEED 15min)',
                    isPrimary: !gameState.miracleGrowActive,
                    icon: const Icon(Icons.play_circle_outline, color: Colors.white, size: 18),
                    onPressed: gameState.miracleGrowActive ? null :
                      () => showEmpireSnackbar(context, 'Disabled for local testing.', color: EmpireTheme.errorRed),
                  ),
                  if (gameState.miracleGrowActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('ACTIVE: ${(gameState.miracleGrowTimeRemaining / 60).toStringAsFixed(0)} min left', style: GoogleFonts.oswald(fontSize: 14, color: EmpireTheme.neonGreen)),
                    ),
                  const SizedBox(height: 8),
                  EmpireButton(
                    text: 'MORNING RUSH (2x OFFLINE)',
                    isPrimary: false,
                    icon: const Icon(Icons.play_circle_outline, color: Colors.white, size: 18),
                    onPressed: () => showEmpireSnackbar(context, 'Disabled for local testing.', color: EmpireTheme.errorRed),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Time Warps
            Text('TIME WARPS', style: EmpireTheme.headerStyle),
            const Text('Skip hours of production instantly!', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const Divider(color: Colors.white24, thickness: 1),
            Row(children: [
              Expanded(child: EmpireCard(child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  Text('4 HRS', style: GoogleFonts.bangers(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 4),
                  EmpireButton(text: '100 BARS', isPrimary: gameState.goldBars >= 100, onPressed: gameState.goldBars >= 100 ? () => context.read<GameState>().timeWarp(4, 100) : null),
                ]),
              ))),
              const SizedBox(width: 8),
              Expanded(child: EmpireCard(child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  Text('12 HRS', style: GoogleFonts.bangers(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 4),
                  EmpireButton(text: '250 BARS', isPrimary: gameState.goldBars >= 250, onPressed: gameState.goldBars >= 250 ? () => context.read<GameState>().timeWarp(12, 250) : null),
                ]),
              ))),
              const SizedBox(width: 8),
              Expanded(child: EmpireCard(child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  Text('24 HRS', style: GoogleFonts.bangers(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 4),
                  EmpireButton(text: '450 BARS', isPrimary: gameState.goldBars >= 450, onPressed: gameState.goldBars >= 450 ? () => context.read<GameState>().timeWarp(24, 450) : null),
                ]),
              ))),
            ]),
            const SizedBox(height: 24),

            Text('SETTINGS & VISUALS', style: EmpireTheme.headerStyle),
            const Divider(color: Colors.white24, thickness: 1),
            EmpireCard(
              child: SwitchListTile(
                title: Text('Enable Modern Graphics', style: EmpireTheme.bodyStyle.copyWith(color: Colors.white)),
                value: gameState.enableVisualUpgrades,
                activeThumbColor: EmpireTheme.neonGreen,
                onChanged: (val) => context.read<GameState>().toggleVisualUpgrades(val),
              ),
            ),
            
            const SizedBox(height: 30),
            
            Text('HEAT LEVEL', style: EmpireTheme.headerStyle.copyWith(color: EmpireTheme.errorRed)),
            const Divider(color: Colors.white24, thickness: 1),
            if (gameState.cash < 500 && gameState.streetCred == 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You are too small time for the cops to care. Earn at least \$500 to trigger a bust.',
                  style: EmpireTheme.bodyStyle.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            if (gameState.cash >= 500 || gameState.streetCred > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EmpireTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EmpireTheme.errorRed, width: 2)
                ),
                child: Column(
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Flexible(child: Text('TOTAL BUSTS:', style: GoogleFonts.bangers(fontSize: 20, color: Colors.white, letterSpacing: 1))),
                         Flexible(child: Text('${gameState.totalBusts}', style: GoogleFonts.oswald(fontSize: 22, color: EmpireTheme.errorRed, fontWeight: FontWeight.bold))),
                     ]),
                     const SizedBox(height: 15),
                     ElevatedButton.icon(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: EmpireTheme.errorRed, 
                         padding: const EdgeInsets.all(16),
                         minimumSize: const Size(double.infinity, 50),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       icon: const Icon(Icons.local_police, color: Colors.white),
                       label: Text('TAKE THE FALL (PRESTIGE)', style: GoogleFonts.bangers(fontSize: 22, letterSpacing: 1, color: Colors.white)),
                       onPressed: () {
                           showDialog(
                             context: context, 
                             builder: (ctx) => AlertDialog(
                               backgroundColor: EmpireTheme.lightMetal,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 side: const BorderSide(color: EmpireTheme.errorRed, width: 2),
                               ),
                               title: Text('THE COPS ARE HERE!', style: GoogleFonts.bangers(color: EmpireTheme.errorRed, fontSize: 32, letterSpacing: 1)),
                               content: Text('They will seize all your cash, stash, and upgrades. But you will earn Street Cred based on your net worth (${(gameState.cash / 500).floor()} Cred). Start over?', style: EmpireTheme.bodyStyle),
                               actions: [
                                 TextButton(onPressed: () => Navigator.pop(ctx), child: Text('NEVERMIND', style: GoogleFonts.bangers(color: Colors.white54, fontSize: 18))),
                                 EmpireButton(
                                   text: 'DO IT',
                                   isPrimary: false,
                                   onPressed: () {
                                      context.read<GameState>().triggerBust();
                                      Navigator.pop(ctx);
                                   }, 
                                 )
                               ]
                             )
                           );
                       },
                     )
                  ],
                )
              ),
            ]
          ],
        ),
      ),
    );
  }
}
