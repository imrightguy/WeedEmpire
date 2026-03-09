import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

enum BusinessType { lab, streets, office, safe }

class BusinessComponent extends SpriteComponent with HasGameReference, TapCallbacks {
  final BusinessType type;
  final VoidCallback onTap;

  BusinessComponent({
    required this.type,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
    Anchor anchor = Anchor.center,
  }) : super(position: position, size: size, anchor: anchor);

  @override
  Future<void> onLoad() async {
    priority = position.y.toInt();
    final sheet = await game.loadSprite('business_structures.png');
    
    // Slice coordinates based on 1024x1024 sheet
    Vector2 srcPos;
    Vector2 srcSize;

    switch (type) {
      case BusinessType.lab:
        srcPos = Vector2(0, 0);
        srcSize = Vector2(512, 512);
        break;
      case BusinessType.streets:
        srcPos = Vector2(512, 0);
        srcSize = Vector2(512, 512);
        break;
      case BusinessType.office:
        srcPos = Vector2(384, 512); // Office trailer is wide, centered more in bottom right
        srcSize = Vector2(640, 512);
        break;
      case BusinessType.safe:
        srcPos = Vector2(0, 512);
        srcSize = Vector2(512, 512);
        break;
    }

    sprite = Sprite(
      sheet.image,
      srcPosition: srcPos,
      srcSize: srcSize,
    );

    // Add a hitbox at the base of the building
    add(RectangleHitbox(
      size: Vector2(size.x * 0.8, size.y * 0.2),
      position: Vector2(size.x * 0.1, size.y * 0.75),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
