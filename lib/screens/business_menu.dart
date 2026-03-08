import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/game_state.dart';
import '../services/ad_service.dart';
import '../services/play_games_service.dart';
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
          Text('ACTIVE STAFF', style: EmpireTheme.headerStyle),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmployeeSlot(context, gameState, 'lab', 'LAB'),
              _buildEmployeeSlot(context, gameState, 'streets', 'STREETS'),
              _buildEmployeeSlot(context, gameState, 'office', 'OFFICE'),
            ],
          ),
          const SizedBox(height: 16),
          if (gameState.ownedEmployees.isNotEmpty) ...[
            Text('AVAILABLE STAFF', style: EmpireTheme.headerStyle),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: gameState.ownedEmployees.length,
                itemBuilder: (context, index) {
                  final empId = gameState.ownedEmployees[index];
                  if (gameState.equippedEmployees.containsValue(empId)) return const SizedBox.shrink();
                  final emp = gameState.availableEmployees.firstWhere((e) => e.id == empId);
                  return GestureDetector(
                     onTap: () => context.read<GameState>().equipEmployee(emp.id, emp.role),
                     child: Container(
                       width: 130,
                       margin: const EdgeInsets.only(right: 8),
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(
                         color: EmpireTheme.lightMetal,
                         border: Border.all(color: _getRarityColor(emp.rarity), width: 2),
                         borderRadius: BorderRadius.circular(8)
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(emp.name, style: GoogleFonts.bangers(fontSize: 16, color: _getRarityColor(emp.rarity)), textAlign: TextAlign.center, maxLines: 1),
                           Text(emp.role.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 4),
                           Text(emp.description, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center, maxLines: 2),
                           const Spacer(),
                           Text('EQUIP', style: GoogleFonts.oswald(fontSize: 14, color: EmpireTheme.neonGreen)),
                         ]
                       )
                     )
                  );
                }
              )
            ),
            const SizedBox(height: 16),
          ],
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
    final adService = AdService();
    final playGames = PlayGamesService();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Gold Bars HUD
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [EmpireTheme.brightOrange.withValues(alpha: 0.3), EmpireTheme.darkMetal]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: EmpireTheme.brightOrange, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: EmpireTheme.brightOrange, size: 28),
                const SizedBox(width: 8),
                Text('GOLD BARS: ${gameState.goldBars}', style: GoogleFonts.bangers(fontSize: 28, color: EmpireTheme.brightOrange, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                    Expanded(child: EmpireButton(text: 'ACHIEVEMENTS', onPressed: () => playGames.showAchievements())),
                    const SizedBox(width: 8),
                    Expanded(child: EmpireButton(text: 'LEADERBOARD', isPrimary: false, onPressed: () => playGames.showLeaderboard())),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Employee Gacha
          Text('THE GACHA SAFE', style: EmpireTheme.headerStyle),
          const Text('Crack safes to hire new cartel employees!', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
                     const Text('Guaranteed Epic or Legendary!', style: TextStyle(fontSize: 11, color: Colors.white54)),
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
                    () => adService.showRewardedAd(onReward: () => context.read<GameState>().activateMiracleGrow()),
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
                  onPressed: () => adService.showRewardedAd(onReward: () => context.read<GameState>().claimMorningRush(gameState.cash * 0.1)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Time Warps
          Text('TIME WARPS', style: EmpireTheme.headerStyle),
          const Text('Skip hours of production instantly!', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
    );
  }

  Widget _buildEmployeeSlot(BuildContext context, GameState state, String roleId, String roleName) {
    final emp = state.getEquippedForRole(roleId);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: EmpireTheme.darkMetal,
          border: Border.all(color: emp != null ? _getRarityColor(emp.rarity) : Colors.white24),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          children: [
            Text(roleName, style: GoogleFonts.bangers(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 8),
            if (emp != null) ...[
              Text(emp.name, style: GoogleFonts.oswald(fontSize: 14, color: _getRarityColor(emp.rarity)), textAlign: TextAlign.center),
              Text(emp.description, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
              TextButton(
                onPressed: () => state.unequipEmployee(roleId), 
                child: const Text('REMOVE', style: TextStyle(fontSize: 10, color: EmpireTheme.errorRed))
              ),
            ] else ...[
              const Icon(Icons.person_outline, color: Colors.white24, size: 32),
              const SizedBox(height: 24),
            ]
          ]
        )
      )
    );
  }
  
  Color _getRarityColor(EmployeeRarity r) {
    switch (r) {
      case EmployeeRarity.common: return Colors.white70;
      case EmployeeRarity.rare: return Colors.lightBlueAccent;
      case EmployeeRarity.epic: return Colors.purpleAccent;
      case EmployeeRarity.legendary: return EmpireTheme.brightOrange;
    }
  }
}
