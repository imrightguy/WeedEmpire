import 'dart:math';
import 'package:flame/components.dart';
import '../../state/game_state.dart';
import '../weed_empire_game.dart';
import 'customer_component.dart';

class CustomerSpawner extends Component with HasGameReference<WeedEmpireGame> {
  final GameState gameState;
  final Random _random = Random();
  double _timer = 0;
  
  // Spawn a customer roughly every 3-8 seconds
  double _nextSpawnTime = 5.0;

  CustomerSpawner({required this.gameState});

  @override
  void update(double dt) {
    super.update(dt);
    
    _timer += dt;
    if (_timer >= _nextSpawnTime) {
      _timer = 0;
      _nextSpawnTime = _random.nextDouble() * 5 + 3; // 3 to 8 seconds

      // Only spawn if we don't have too many already (cap at 5 max on screen)
      if (game.children.whereType<CustomerComponent>().length < 5) {
        final amountWanted = _random.nextInt(3) + 1.0; // Wants 1.0 to 3.0 grams
        game.add(CustomerComponent(gameState: gameState, amountWanted: amountWanted));
      }
    }
  }
}
