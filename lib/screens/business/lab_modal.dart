import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/game_state.dart';
import '../widgets/empire_widgets.dart';

class LabModal extends StatelessWidget {
  const LabModal({super.key});

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
            // Strain Selection Header
            Text('PLANT STRAIN', style: EmpireTheme.headerStyle),
            const Divider(color: Colors.white24, thickness: 1),
            // Horizontal list of Strains
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: gameState.strains.length,
                itemBuilder: (context, index) {
                  final strain = gameState.strains[index];
                  final isUnlocked = gameState.unlockedStrains.contains(strain.id);
                  final isActive = gameState.activeStrainIndex == index;
                  final canAfford = gameState.cash >= strain.unlockCost;
                  
                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked && !isActive) {
                        context.read<GameState>().setActiveStrain(strain.id);
                        showEmpireSnackbar(context, 'NOW GROWING: ${strain.name.toUpperCase()}');
                      } else if (!isUnlocked && canAfford) {
                        context.read<GameState>().unlockStrain(strain.id);
                        showEmpireSnackbar(context, '🌿 UNLOCKED: ${strain.name.toUpperCase()}!', color: EmpireTheme.brightOrange);
                      }
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isActive ? EmpireTheme.darkMetal : EmpireTheme.lightMetal,
                        border: Border.all(
                          color: isActive ? EmpireTheme.neonGreen : (isUnlocked ? Colors.white54 : EmpireTheme.errorRed),
                          width: isActive ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(strain.name, style: GoogleFonts.bangers(fontSize: 16, color: isActive ? EmpireTheme.neonGreen : Colors.white), textAlign: TextAlign.center, maxLines: 1),
                          const SizedBox(height: 4),
                          if (isActive)
                             Text('GROWING', style: GoogleFonts.oswald(fontSize: 14, color: EmpireTheme.neonGreen, fontWeight: FontWeight.bold))
                          else if (isUnlocked)
                             Text('SWITCH', style: GoogleFonts.oswald(fontSize: 14, color: Colors.white70))
                          else
                             Text('UNLOCK: \$${strain.unlockCost.toStringAsFixed(0)}', style: GoogleFonts.oswald(fontSize: 14, color: canAfford ? EmpireTheme.brightOrange : EmpireTheme.errorRed)),
                          const SizedBox(height: 2),
                          Text('\$${strain.sellPrice.toStringAsFixed(0)}/g', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('AUTO-GROW RATE', style: EmpireTheme.bodyStyle)),
                Flexible(child: Text('${gameState.autoGrowRate.toStringAsFixed(1)} g/s', style: GoogleFonts.oswald(fontSize: 20, color: EmpireTheme.neonGreen))),
              ],
            ),
            const SizedBox(height: 16),
            EmpireButton(
              text: 'MANUAL GROW (+1g)',
              onPressed: () => context.read<GameState>().growWeed(1.0),
            ),
            const SizedBox(height: 24),
            Text('LAB UPGRADES', style: EmpireTheme.headerStyle),
            const Divider(color: Colors.white24, thickness: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = gameState.upgrades[index];
                if (upgrade.id != 'heat_lamp' && upgrade.id != 'shed_expansion') return const SizedBox.shrink();
                
                final canAfford = gameState.cash >= upgrade.currentCost;
                return EmpireCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      title: Text(upgrade.name, style: GoogleFonts.bangers(fontSize: 20, color: Colors.white, letterSpacing: 1)),
                      subtitle: Text('${upgrade.description}\nLevel: ${upgrade.level}', style: EmpireTheme.bodyStyle.copyWith(color: Colors.white70)),
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
