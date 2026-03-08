import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/game_state.dart';
import 'widgets/empire_widgets.dart';

class BusinessMenu extends StatelessWidget {
  const BusinessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Container(
      color: EmpireTheme.darkMetal,
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'WeedEmpire',
                style: GoogleFonts.bangers(fontSize: 42, color: EmpireTheme.neonGreen, letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Global HUD
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

            // Tabs
            const TabBar(
              indicatorColor: EmpireTheme.neonGreen,
              labelColor: EmpireTheme.neonGreen,
              unselectedLabelColor: Colors.white54,
              indicatorWeight: 4,
              tabs: [
                Tab(icon: Icon(Icons.science), text: 'LAB'),
                Tab(icon: Icon(Icons.storefront), text: 'STREETS'),
                Tab(icon: Icon(Icons.business_center), text: 'OFFICE'),
                Tab(icon: Icon(Icons.vpn_key), text: 'SAFE'),
              ],
            ),
            const Divider(color: Colors.black, height: 1, thickness: 2),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildLabView(context, gameState),
                  _buildStreetsView(context, gameState),
                  _buildOfficeView(context, gameState),
                  _buildSafeView(context, gameState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  // --- TAB 1: THE LAB (Growing & Upgrades) ---
  Widget _buildLabView(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    } else if (!isUnlocked && canAfford) {
                      context.read<GameState>().unlockStrain(strain.id);
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
          Expanded(
            child: ListView.builder(
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = gameState.upgrades[index];
                if (upgrade.id != 'lamp' && upgrade.id != 'shed') return const SizedBox.shrink();
                
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
          ),
        ],
      ),
    );
  }

  // --- TAB 2: THE STREETS (Selling & Dealers) ---
  Widget _buildStreetsView(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          Expanded(
            child: ListView.builder(
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = gameState.upgrades[index];
                if (upgrade.id != 'dealer') return const SizedBox.shrink();
                
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
          ),
        ],
      ),
    );
  }

  // --- TAB 3: THE OFFICE (Employees & Real Estate) ---
  Widget _buildOfficeView(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('REAL ESTATE MARKET', style: EmpireTheme.headerStyle),
          const Text('Buy new locations to massively increase your maximum stash limit.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const Divider(color: Colors.white24, thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.locations.length,
              itemBuilder: (context, index) {
                final loc = gameState.locations[index];
                
                final isCurrent = index == gameState.currentLocationIndex;
                final isOwned = index <= gameState.currentLocationIndex;
                final canAfford = gameState.cash >= loc.cost;
                
                return EmpireCard(
                  isHighlighted: isCurrent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      title: Text(loc.name, style: GoogleFonts.bangers(fontSize: 20, color: isCurrent ? EmpireTheme.brightOrange : Colors.white, letterSpacing: 1)),
                      subtitle: Text('${loc.description}\nMax Stash Boost: +${loc.stashBoost.toStringAsFixed(0)}g', style: EmpireTheme.bodyStyle),
                      trailing: isOwned 
                        ? Text(isCurrent ? 'ACTIVE' : 'OWNED', style: GoogleFonts.oswald(color: EmpireTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.bold))
                        : EmpireButton(
                            text: '\$${loc.cost.toStringAsFixed(0)}',
                            isPrimary: canAfford,
                            onPressed: canAfford ? () => context.read<GameState>().buyLocation(index) : null,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: THE SAFE (Prestige & Settings) ---
  Widget _buildSafeView(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
    );
  }
}
