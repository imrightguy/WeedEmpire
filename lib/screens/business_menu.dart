import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/game_state.dart';

class BusinessMenu extends StatelessWidget {
  const BusinessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch game state so the whole menu rebuilds when variables change
    final gameState = context.watch<GameState>();
    
    return Container(
      color: Colors.black87,
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Weed Empire',
                style: GoogleFonts.bangers(fontSize: 42, color: Colors.greenAccent, letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Global HUD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHudItem('Cash', '\$${gameState.cash.toStringAsFixed(2)}', Colors.lightGreenAccent),
                  _buildHudItem('Stash', '${gameState.weedStash.toStringAsFixed(1)}g', Colors.white),
                  if (gameState.streetCred > 0)
                    _buildHudItem('Cred', '${gameState.streetCred}', Colors.redAccent),
                ],
              ),
            ),

            // Active Event Banner
            if (gameState.activeEvent != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.redAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      gameState.activeEvent!.title,
                      style: GoogleFonts.bangers(fontSize: 24, color: Colors.redAccent, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gameState.activeEvent!.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      icon: const Icon(Icons.campaign, color: Colors.white),
                      label: Text('HIRE TRUTH TUBER (10 Cred)', style: GoogleFonts.bangers(fontSize: 18, color: Colors.white)),
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
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.greenAccent,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(icon: Icon(Icons.science), text: 'LAB'),
                Tab(icon: Icon(Icons.storefront), text: 'STREETS'),
                Tab(icon: Icon(Icons.business_center), text: 'OFFICE'),
                Tab(icon: Icon(Icons.vpn_key), text: 'SAFE'),
              ],
            ),

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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        Text(value, style: GoogleFonts.oswald(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Auto-Grow:', style: const TextStyle(fontSize: 18, color: Colors.white70)),
              Text('${gameState.autoGrowRate.toStringAsFixed(1)} g/s', style: GoogleFonts.oswald(fontSize: 18, color: Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
            onPressed: () => context.read<GameState>().growWeed(1.0),
            child: Text('MANUAL GROW (+1g)', style: GoogleFonts.bangers(fontSize: 24)),
          ),
          const SizedBox(height: 20),
          Text('Lab Upgrades', style: GoogleFonts.bangers(fontSize: 24, color: Colors.white)),
          const Divider(color: Colors.white54),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = gameState.upgrades[index];
                // Only show grow/stash upgrades in the lab
                if (upgrade.id != 'lamp' && upgrade.id != 'shed') return const SizedBox.shrink();
                
                final canAfford = gameState.cash >= upgrade.currentCost;
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(upgrade.name, style: GoogleFonts.oswald(fontSize: 18, color: Colors.white)),
                    subtitle: Text('${upgrade.description}\nLevel: ${upgrade.level}', style: const TextStyle(color: Colors.white70)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: canAfford ? Colors.orange : Colors.grey),
                      onPressed: canAfford ? () => context.read<GameState>().buyUpgrade(upgrade.id) : null,
                      child: Text('\$${upgrade.currentCost.toStringAsFixed(2)}'),
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
              Text('Auto-Sell:', style: const TextStyle(fontSize: 18, color: Colors.white70)),
              Text('${gameState.autoSellRate.toStringAsFixed(1)} g/s', style: GoogleFonts.oswald(fontSize: 18, color: Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.all(16)),
            onPressed: () => context.read<GameState>().sellWeed(1.0),
            child: Text('HUSTLE (+1g Sold)', style: GoogleFonts.bangers(fontSize: 24, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          Text('Street Upgrades', style: GoogleFonts.bangers(fontSize: 24, color: Colors.white)),
          const Divider(color: Colors.white54),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = gameState.upgrades[index];
                // Only show selling upgrades here
                if (upgrade.id != 'dealer') return const SizedBox.shrink();
                
                final canAfford = gameState.cash >= upgrade.currentCost;
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(upgrade.name, style: GoogleFonts.oswald(fontSize: 18, color: Colors.white)),
                    subtitle: Text('${upgrade.description}\nLevel: ${upgrade.level}', style: const TextStyle(color: Colors.white70)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: canAfford ? Colors.orange : Colors.grey),
                      onPressed: canAfford ? () => context.read<GameState>().buyUpgrade(upgrade.id) : null,
                      child: Text('\$${upgrade.currentCost.toStringAsFixed(2)}'),
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

  // --- TAB 3: THE OFFICE (Employees & Real Estate - Phase 4) ---
  Widget _buildOfficeView(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Real Estate Market', style: GoogleFonts.bangers(fontSize: 24, color: Colors.white)),
          const Divider(color: Colors.white54),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.locations.length,
              itemBuilder: (context, index) {
                final loc = gameState.locations[index];
                
                final isCurrent = index == gameState.currentLocationIndex;
                final isOwned = index <= gameState.currentLocationIndex;
                final canAfford = gameState.cash >= loc.cost;
                
                return Card(
                  color: isCurrent ? Colors.purple[900] : Colors.grey[850],
                  child: ListTile(
                    title: Text(loc.name, style: GoogleFonts.oswald(fontSize: 18, color: Colors.white)),
                    subtitle: Text('${loc.description}\nMax Stash Boost: +${loc.stashBoost.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.white70)),
                    trailing: isOwned 
                      ? Text(isCurrent ? 'ACTIVE' : 'OWNED', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: canAfford ? Colors.orange : Colors.grey),
                          onPressed: canAfford ? () => context.read<GameState>().buyLocation(index) : null,
                          child: Text('\$${loc.cost.toStringAsFixed(2)}'),
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
          Text('Settings & Visuals', style: GoogleFonts.bangers(fontSize: 24, color: Colors.white)),
          const Divider(color: Colors.white54),
          SwitchListTile(
            title: const Text('Enable Modern Graphics', style: TextStyle(color: Colors.white70)),
            value: gameState.enableVisualUpgrades,
            activeThumbColor: Colors.greenAccent,
            onChanged: (val) => context.read<GameState>().toggleVisualUpgrades(val),
          ),
          
          const SizedBox(height: 30),
          
          Text('Heat Level', style: GoogleFonts.bangers(fontSize: 24, color: Colors.redAccent)),
          const Divider(color: Colors.white54),
          if (gameState.cash < 500 && gameState.streetCred == 0)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'You are too small time for the cops to care. Earn at least \$500 to trigger a bust.',
                style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              ),
            ),
          if (gameState.cash >= 500 || gameState.streetCred > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent)
              ),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Total Busts:', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                       Text('${gameState.totalBusts}', style: GoogleFonts.oswald(fontSize: 18, color: Colors.white)),
                   ]),
                   const SizedBox(height: 15),
                   ElevatedButton.icon(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.redAccent, 
                       padding: const EdgeInsets.all(16),
                       minimumSize: const Size(double.infinity, 50),
                     ),
                     icon: const Icon(Icons.local_police, color: Colors.white),
                     label: Text('TAKE THE FALL (PRESTIGE)', style: GoogleFonts.bangers(fontSize: 22, letterSpacing: 1, color: Colors.white)),
                     onPressed: () {
                         showDialog(
                           context: context, 
                           builder: (ctx) => AlertDialog(
                             backgroundColor: Colors.grey[900],
                             title: Text('The Cops are here!', style: GoogleFonts.bangers(color: Colors.redAccent, fontSize: 32)),
                             content: Text('They will seize all your cash, stash, and upgrades. But you will earn Street Cred based on your net worth (${(gameState.cash / 500).floor()} Cred). Start over?', style: const TextStyle(color: Colors.white)),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nevermind', style: TextStyle(color: Colors.white54))),
                               TextButton(
                                 onPressed: () {
                                    context.read<GameState>().triggerBust();
                                    Navigator.pop(ctx);
                                 }, 
                                 child: const Text('Do it.', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
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
