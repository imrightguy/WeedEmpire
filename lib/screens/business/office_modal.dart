import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/game_state.dart';
import '../widgets/empire_widgets.dart';

class OfficeModal extends StatelessWidget {
  const OfficeModal({super.key});

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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
        ),
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
                child: const Text('REMOVE', style: const TextStyle(fontSize: 10, color: EmpireTheme.errorRed))
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
