import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';
import 'components/customer_spawner.dart';
import 'components/player_avatar_component.dart';
import 'components/map_manager.dart';
import 'components/business_component.dart';
import 'components/mother_plant_component.dart';

// The core Flame Game class managing 2D rendering and loop.
class WeedEmpireGame extends FlameGame with TapCallbacks, DragCallbacks, HasCollisionDetection {
  final GameState gameState;
  
  late final World gameWorld;
  late final CameraComponent gameCamera;
  
  late final SpriteComponent _backgroundMap;
  late final MotherPlantComponent _motherPlant;
  late final CustomerSpawner _customerSpawner;
  late final PlayerAvatarComponent _playerAvatar;
  late final MapManager _mapManager;
  late final JoystickComponent _joystick;

  // External UI callbacks to open business modals
  final Map<BusinessType, VoidCallback> businessCallbacks = {};
  
  WeedEmpireGame({required this.gameState});

  // Method to set business callbacks from the UI layer
  void setBusinessCallbacks(Map<BusinessType, VoidCallback> callbacks) {
    businessCallbacks.addAll(callbacks);
  }

  @override
  Color backgroundColor() => const Color(0xff222222);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 1. Initialize World and Camera
    gameWorld = World();
    await add(gameWorld);

    gameCamera = CameraComponent(world: gameWorld);
    // Align camera center to 0,0 in the world
    gameCamera.viewfinder.anchor = Anchor.center;
    await add(gameCamera);

    // 2. Load the large neighborhood map into the World
    final bgSprite = await loadSprite('world_map.png');
    
    // Make the map arbitrarily large (e.g., 2500x2500)
    _backgroundMap = SpriteComponent(
      sprite: bgSprite,
      size: Vector2(2500, 2500), 
      anchor: Anchor.center, 
      priority: -1000,
    );
    await gameWorld.add(_backgroundMap);

    // Set camera bounds to not pan off the edge of the background map
    gameCamera.setBounds(
      Rectangle.fromCenter(
        center: Vector2.zero(), 
        size: Vector2(2500, 2500)
      ),
    );

    // 3. Initialize MapManager to spawn businesses
    _mapManager = MapManager(onBusinessTap: businessCallbacks);
    await gameWorld.add(_mapManager);

    // 4. Load Mother Plant (Center Landmark)
    _motherPlant = MotherPlantComponent(
      position: Vector2(0, 150),
      size: Vector2(250, 300),
      onTap: () => businessCallbacks[BusinessType.lab]?.call(),
    );
    await gameWorld.add(_motherPlant);

    // 5. Start spawning customers in the world
    _customerSpawner = CustomerSpawner(gameState: gameState);
    await gameWorld.add(_customerSpawner);

    // 6. Load the Player Avatar
    _playerAvatar = PlayerAvatarComponent();
    await gameWorld.add(_playerAvatar);

    // 7. Add Joystick for movement
    final knobPaint = Paint()..color = Colors.white.withOpacity(0.5);
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.3);
    _joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 1000,
    );
    await add(_joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Drive the idle simulation forward based on the real-time game loop
    gameState.tick(dt);

    if (!gameState.isGodMode) {
      if (!_joystick.delta.isZero()) {
        _playerAvatar.moveWithJoystick(_joystick.delta);
      }
      gameCamera.follow(_playerAvatar);
    } else {
      gameCamera.stop();
    }
  }

  // --- Input Handlers ---

  @override
  void onTapDown(TapDownEvent event) {
    if (!gameState.isGodMode) {
      final worldPos = gameCamera.globalToLocal(event.canvasPosition);
      
      // Check if we hit a building (for UI feedback or interaction, movement is joystick-only now)
      final hitBuilding = gameWorld.componentsAtPoint(worldPos).whereType<BusinessComponent>().isNotEmpty;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameState.isGodMode) {
      // Invert the delta because dragging the screen left means the camera moves right over the world
      gameCamera.viewfinder.position -= event.localDelta;
    }
  }
}
