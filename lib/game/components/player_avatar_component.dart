import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/components.dart';
import 'business_component.dart';
import 'mother_plant_component.dart';
import 'map_manager.dart';
import '../weed_empire_game.dart';

class PlayerAvatarComponent extends PositionComponent with HasGameReference<WeedEmpireGame>, CollisionCallbacks {
  final double _speed = 400.0;
  
  late final SpriteComponent _spriteComponent;

  PlayerAvatarComponent();

  @override
  Future<void> onLoad() async {
    final avatarSprite = await game.loadSprite('player_avatar.png');
    
    final avatarHeight = 150.0;
    final double aspectRatio = avatarSprite.srcSize.y > 0 ? (avatarSprite.srcSize.x / avatarSprite.srcSize.y) : 0.5;
    
    size = Vector2(avatarHeight * aspectRatio, avatarHeight);
    anchor = Anchor.bottomCenter;
    position = Vector2(0, 0); 

    _spriteComponent = SpriteComponent(
      sprite: avatarSprite,
      size: size,
      anchor: Anchor.bottomCenter,
    );
    add(_spriteComponent);
    
    // Add hitbox for collisions at the feet
    add(RectangleHitbox(
      size: Vector2(size.x * 0.6, 20),
      position: Vector2(size.x * 0.2, size.y - 20), // At the very bottom
    ));
  }

  double _walkTimer = 0;
  bool _isWalking = false;
  Vector2 _lastDelta = Vector2.zero();

  void moveWithJoystick(Vector2 delta) {
    _lastDelta = delta;
    _isWalking = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isWalking && !_lastDelta.isZero()) {
      final direction = _lastDelta.normalized();
      
      // Check if we hit a building before moving
      // Note: We cast the position to an Offset for the Rect.contains check
      final hitBuilding = game.children.whereType<MapManager>().expand((mm) => mm.children).whereType<BusinessComponent>().any((business) =>
          business.toRect().contains((position + direction * _speed * dt).toOffset()));

      if (!hitBuilding) {
        position += direction * _speed * dt;
      }
      
      // Flip sprite based on direction
      if (direction.x > 0 && _spriteComponent.scale.x < 0) _spriteComponent.scale.x = _spriteComponent.scale.x.abs();
      if (direction.x < 0 && _spriteComponent.scale.x > 0) _spriteComponent.scale.x = -_spriteComponent.scale.x.abs();

      // Procedural walk animation (Bob & Tilt)
      _walkTimer += dt * 10;
      _spriteComponent.angle = 0.08 * (direction.x > 0 ? 1 : -1) * (1 - ( ( ( (_walkTimer * 1.5) % (3.14 * 2) ) - 3.14 ).abs() / 1.57 ));
      _spriteComponent.position.y = -2.0 * (1 - ( ( ( (_walkTimer * 3.0) % (3.14 * 2) ) - 3.14 ).abs() / 1.57 ));
      
      // Reset walk state for next frame (Joystick is continuous)
      _isWalking = false;
    } else {
      _spriteComponent.angle = 0;
      _spriteComponent.position.y = 0;
    }
    
    // Y-sorting
    priority = position.y.toInt();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is BusinessComponent || other is MotherPlantComponent) {
      // Basic wall push-back: move back by the penetration depth
      if (intersectionPoints.isNotEmpty) {
        final mid = intersectionPoints.reduce((a, b) => a + b) / intersectionPoints.length.toDouble();
        final pushDir = (position - mid).normalized();
        position += pushDir * 5.0; // Small push to separate
      }
    }
  }
}
