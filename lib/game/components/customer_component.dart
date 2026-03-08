import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../state/game_state.dart';
import '../weed_empire_game.dart';

class CustomerComponent extends PositionComponent with TapCallbacks, HasGameReference<WeedEmpireGame> {
  final double amountWanted;
  final GameState gameState;
  late TextComponent _textBadge;

  // Simple state for moving
  double _speed = 50.0;
  bool _isSatisfied = false;

  CustomerComponent({
    required this.gameState, 
    this.amountWanted = 1.0,
  }) : super(size: Vector2(40, 60)); // Placeholder hitbox

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Placeholder shape for a customer (e.g., a stick figure or colored rectangle)
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blueAccent,
    ));

    // Text showing what they want
    _textBadge = TextComponent(
      text: '${amountWanted}g',
      position: Vector2(size.x / 2, -15),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
    add(_textBadge);

    // Start on the left side of the screen
    position = Vector2(-size.x, game.size.y * 0.7 + (Random().nextDouble() * 50));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Walk to the right
    if (!_isSatisfied) {
      position.x += _speed * dt;
      // Stop near the plant
      if (position.x > game.size.x * 0.35 + (Random().nextDouble() * 50)) {
         _speed = 0; // Wait for weed
      }
    } else {
       // Walk away off screen
      position.x += 100 * dt;
      if (position.x > game.size.x + 100) {
        removeFromParent();
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isSatisfied) return;

    if (gameState.activeStrainStash >= amountWanted) {
      gameState.sellWeed(amountWanted);
      _isSatisfied = true;
      _textBadge.text = 'Thanks!';
      _textBadge.textRenderer = TextPaint(
        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
      );
    } else {
      _textBadge.text = 'Need more!';
      _textBadge.textRenderer = TextPaint(
        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
      );
      // Reset text after a second
      Future.delayed(const Duration(seconds: 1), () {
        if (!isMounted || _isSatisfied) return;
        _textBadge.text = '${amountWanted}g';
        _textBadge.textRenderer = TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        );
      });
    }
  }
}
