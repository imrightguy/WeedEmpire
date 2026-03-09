import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/game_state.dart';
import '../widgets/empire_widgets.dart';

class StreetsModal extends StatelessWidget {
  const StreetsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Container(
      color: EmpireTheme.darkMetal,
      padding: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('AUTO-SELL RATE', style: EmpireTheme.bodyStyle)),
                Flexible(child: Text('${gameState.autoSellRate.toStringAsFixed(1)} g/s', style: GoogleFonts.oswald(fontSize: 20, color: EmpireTheme.neonGreen))),
              ],
            ),
            const SizedBox(height: 16),
            EmpireButton(
              text: 'HUSTLE (+1g SOLD)',
              isPrimary: false,
              onPressed: () => context.read<GameState>().sellWeed(1.0),
            ),
            const SizedBox(height: 24),
            Text('STREET UPGRADES', style: EmpireTheme.headerStyle),
            const Divider(color: Colors.white24, thickness: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                  final upgrade = gameState.upgrades[index];
                  if (upgrade.id != 'corner_dealer') return const SizedBox.shrink();
                  
                  final canAfford = gameState.cash >= upgrade.currentCost;
                  return EmpireCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: ListTile(
                        title: Text(upgrade.name, style: GoogleFonts.bangers(fontSize: 20, color: Colors.white, letterSpacing: 1)),
                        subtitle: Text('${upgrade.description}\nLevel: ${upgrade.level}', style: EmpireTheme.bodyStyle),
                        trailing: EmpireButton(
                          text: '\$${upgrade.currentCost.toStringAsFixed(2)}',
                          isPrimary: canAfford,
                          onPressed: canAfford ? () => context.read<GameState>().buyUpgrade(upgrade.id) : null,
                        ),
                      ),
                    ),
                  );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}
