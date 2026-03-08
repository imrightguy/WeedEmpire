import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';
import 'components/customer_spawner.dart';

// The core Flame Game class managing 2D rendering and loop.
class WeedEmpireGame extends FlameGame with HasCollisionDetection {
  final GameState gameState;
  late final SpriteComponent _background;
  late final SpriteComponent _weedPlant;
  late final CustomerSpawner _customerSpawner;
  
  String _currentBgAsset = '';

  WeedEmpireGame({required this.gameState});

  @override
  Color backgroundColor() => const Color(0xff222222);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load background
    _currentBgAsset = gameState.currentLocation.assetPath;
    final bgSprite = await loadSprite(_currentBgAsset);
    _background = SpriteComponent(
      sprite: bgSprite,
      size: Vector2(size.x, size.y), // Scale to fill the screen initially
    );
    add(_background);

    // Load weed plant
    final plantSprite = await loadSprite('weed_plant.png');
    
    // Calculate a nice size for the plant (maybe 1/3 of the screen height)
    final plantHeight = size.y * 0.4;
    final plantWidth = plantHeight * (plantSprite.srcSize.x / plantSprite.srcSize.y);

    _weedPlant = SpriteComponent(
      sprite: plantSprite,
      size: Vector2(plantWidth, plantHeight),
      anchor: Anchor.bottomCenter,
    );
    
    // Position it roughly in the center-bottom of the screen (on some grass/dirt)
    _weedPlant.position = Vector2(size.x / 2, size.y * 0.85);
    add(_weedPlant);

    // Start spawning customers
    _customerSpawner = CustomerSpawner(gameState: gameState);
    add(_customerSpawner);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Drive the idle simulation forward based on the real-time game loop
    gameState.tick(dt);
    
    // Check if location changed
    if (isLoaded && _currentBgAsset != gameState.currentLocation.assetPath) {
      _currentBgAsset = gameState.currentLocation.assetPath;
      _updateBackgroundSprite();
    }
  }

  Future<void> _updateBackgroundSprite() async {
    _background.sprite = await loadSprite(_currentBgAsset);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Ensure background scales to fill the new layout if the window is resized
    if (isLoaded) {
      _background.size = size;

      final plantHeight = size.y * 0.4;
      final plantWidth = plantHeight * (_weedPlant.sprite!.srcSize.x / _weedPlant.sprite!.srcSize.y);
      _weedPlant.size = Vector2(plantWidth, plantHeight);
      _weedPlant.position = Vector2(size.x / 2, size.y * 0.85);
    }
  }
}


