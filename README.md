# Weed Empire

A multiplatform (Mobile & Desktop) idle growing and business simulation game built with Flutter and the Flame Engine.
Inspired by the gritty, cartoon-vector aesthetic of Trailer Park Boys.

## Features Currently Implemented
*   **Flame Engine Integration**: A seamless 2D game canvas rendering AI-generated vector environments and sprites alongside standard Flutter UI (`ChangeNotifier` powered).
*   **Responsive Layouts**: The UI dynamically adapts its layout depending on whether you are running a portrait (mobile) or landscape (desktop/web) window.
*   **Idle Resource Generation**: Watch your stash grow over time with background logic mapped natively to the `update(dt)` loop.
*   **Offline Progression**: Fully serialized `shared_preferences` State allows players to close the app and return to calculated idle profits later.
*   **Active Selling**: Tap procedurally spawned customers (`CustomerComponent`) walking across the Flame canvas to sell your stash for cash.
*   **Passive Selling Upgrades**: Hire 'The Corner Dealer' to automatically automate sales.
*   **"Get Busted" Prestige System**: The police will seize your cash and stash, but reward your net worth with permanent meta-currency ("Street Cred").

## Running the Game

```bash
# Run on Linux/macOS/Windows desktops
flutter run -d linux

# Run on a connected mobile device or emulator
flutter run -d <device_id>
```
