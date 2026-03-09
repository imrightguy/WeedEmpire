import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../weed_empire_game.dart';
import 'business_component.dart';

class MapManager extends Component with HasGameReference<WeedEmpireGame> {
  final Map<BusinessType, VoidCallback> onBusinessTap;

  MapManager({required this.onBusinessTap});

  @override
  Future<void> onLoad() async {
    final gameState = game.gameState;
    
    // Lab: Always present as the starting base
    await add(BusinessComponent(
      type: BusinessType.lab,
      position: Vector2(-300, -300),
      size: Vector2(400, 400),
      onTap: () => onBusinessTap[BusinessType.lab]?.call(),
    ));

    // Streets: Spawns once Corner Dealer is purchased
    if (gameState.upgrades.any((u) => u.id == 'corner_dealer' && u.level > 0)) {
      await add(BusinessComponent(
        type: BusinessType.streets,
        position: Vector2(300, -300),
        size: Vector2(450, 450),
        onTap: () => onBusinessTap[BusinessType.streets]?.call(),
      ));
    }

    // Office: Spawns once player reaches $1,000
    if (gameState.cash >= 1000) {
      await add(BusinessComponent(
        type: BusinessType.office,
        position: Vector2(350, 350),
        size: Vector2(500, 400),
        onTap: () => onBusinessTap[BusinessType.office]?.call(),
      ));
    }

    // Safe: Spawns once player earns 10 Street Cred or rolls an employee
    if (gameState.streetCred >= 10 || gameState.ownedEmployees.isNotEmpty) {
      await add(BusinessComponent(
        type: BusinessType.safe,
        position: Vector2(-350, 350),
        size: Vector2(400, 400),
        onTap: () => onBusinessTap[BusinessType.safe]?.call(),
      ));
    }
  }
}
