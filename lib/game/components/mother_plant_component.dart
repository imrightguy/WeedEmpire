import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class MotherPlantComponent extends SpriteComponent with HasGameReference, TapCallbacks {
  final VoidCallback onTap;

  MotherPlantComponent({
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    priority = position.y.toInt();
    sprite = await game.loadSprite('weed_plant.png');
    
    // Add hitbox for tapping and potential collisions
    add(RectangleHitbox(
      size: Vector2(size.x * 0.6, size.y * 0.8),
      position: Vector2(size.x * 0.2, size.y * 0.1),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
