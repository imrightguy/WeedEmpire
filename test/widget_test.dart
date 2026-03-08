import 'package:flutter_test/flutter_test.dart';
import 'package:weed_empire/state/game_state.dart';

void main() {
  test('GameState initializes with base values', () {
    final gameState = GameState();
    
    expect(gameState.cash, 0.0);
    expect(gameState.weedStash, 0.0);
    expect(gameState.streetCred, 0);
    expect(gameState.unlockedStrains.length, 1);
    expect(gameState.activeStrain.id, 'trailer_trash');
  });
}
