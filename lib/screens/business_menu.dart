import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';

class BusinessMenu extends StatelessWidget {
  const BusinessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Weed Empire Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            textAlign: TextAlign.center,
          ),
          SwitchListTile(
            title: const Text('Enable Modern Graphics', style: TextStyle(color: Colors.white70)),
            value: gameState.enableVisualUpgrades,
            activeThumbColor: Colors.greenAccent,
            onChanged: (val) => context.read<GameState>().toggleVisualUpgrades(val),
          ),
          const SizedBox(height: 10),
          _buildStatRow('Cash:', '\$${gameState.cash.toStringAsFixed(2)}'),
          _buildStatRow('Stash:', '${gameState.weedStash.toStringAsFixed(1)} / ${gameState.maxStash.toStringAsFixed(0)} g'),
          _buildStatRow('Auto-Grow:', '${gameState.autoGrowRate.toStringAsFixed(1)} g/s'),
          if (gameState.autoSellRate > 0) _buildStatRow('Auto-Sell:', '${gameState.autoSellRate.toStringAsFixed(1)} g/s'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(12)),
                  onPressed: () => context.read<GameState>().growWeed(1.0),
                  child: const Text('Grow (1g)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.all(12)),
                  onPressed: () => context.read<GameState>().sellWeed(1.0),
                  child: const Text('Sell (1g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          if (gameState.cash > 1000 || gameState.streetCred > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent)
              ),
              child: Column(
                children: [
                   _buildStatRow('Street Cred:', '${gameState.streetCred}'),
                   const SizedBox(height: 5),
                   ElevatedButton(
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(12)),
                     onPressed: () {
                         showDialog(
                           context: context, 
                           builder: (ctx) => AlertDialog(
                             title: const Text('Get Busted?'),
                             content: Text('The cops will seize all your cash, stash, and upgrades. But you will earn Street Cred based on your net worth (${(gameState.cash / 1000).floor() + 1} Cred). Proceed?'),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nevermind')),
                               TextButton(
                                 onPressed: () {
                                    context.read<GameState>().triggerBust();
                                    Navigator.pop(ctx);
                                 }, 
                                 child: const Text('Do it.', style: TextStyle(color: Colors.redAccent))
                               )
                             ]
                           )
                         );
                     },
                     child: const Text('Trigger Bust (Prestige)'),
                   )
                ],
              )
            ),
            const SizedBox(height: 15),
          ],

          const Text('Upgrades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const Divider(color: Colors.white54),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = gameState.upgrades[index];
                final canAfford = gameState.cash >= upgrade.currentCost;
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(upgrade.name, style: const TextStyle(color: Colors.white)),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 20, color: Colors.white70)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
