# Weed Empire

A multiplatform (Mobile & Desktop) idle growing and business simulation game built with Flutter and the Flame Engine. 
The game features a gritty, cartoon-vector aesthetic inspired by *Trailer Park Boys*.

## Game Vision
The goal of Weed Empire is to grow from a small-time trailer park operation into a massive, multi-location cartel. Players will manage resources, hire eccentric characters, deal with dynamic market fluctuations, and avoid (or bribe) the authorities. 

The game is designed with a long-term progression loop in mind, focusing on player retention and eventual monetization through strategic in-app purchases and optional rewarded ads.

## Core Features (Currently Implemented)
*   **Flame Engine Integration**: A seamless 2D game canvas rendering AI-generated vector environments and sprites alongside a standard Flutter UI.
*   **Responsive Layouts**: The UI dynamically adapts its layout depending on whether you are running a portrait (mobile) or landscape (desktop/web) window.
*   **Idle Resource Generation**: Stash grows automatically over time, driven by background logic mapped natively to the Flame `update(dt)` loop.
*   **Offline Progression**: Fully serialized state using `shared_preferences`. The game calculates offline time elapsed and awards idle profits when the app is reopened.
*   **Active & Passive Selling**: 
    *   Tap procedurally spawned customers (`CustomerComponent`) walking across the Flame canvas to sell stash manually.
    *   Hire 'The Corner Dealer' to automate sales for passive income.
*   **"Get Busted" Prestige System**: The police will seize your cash and stash, but reward your net worth with permanent meta-currency ("Street Cred") used to unlock powerful permanent boosts.
*   **Aesthetics Toggle**: Players can toggle "Modern Graphics" on/off, providing flexibility for future art direction changes without alienating fans of the original gritty look.

## The Bigger Plan (Upcoming Features)

### 1. Expanded Economy & Mechanics
*   **Multiple Strains**: Unlock different types of weed (e.g., "Trailer Trash", "Diamond Kush") with varying grow times, market values, and customer demands.
*   **Dynamic Market**: Prices fluctuate. Players must watch the market to sell high, or store their stash when prices crash.
*   **Employee Management**: Hire managers, trimmers, and security guards. Each character has unique stats, salaries, and personalities.

### 2. Events & Risks
*   **Police Raids**: Random events where the player must decide to bribe cops, hide stash, or take the bust. 
*   **Rival Gangs**: Defend your turf or expand into new territories.

### 3. Locations & Real Estate
*   **Visual Progression**: Move from the Trailer Park to a Suburban House, an Underground Bunker, and eventually a Cartel Mansion. Each location unlocks new mechanics and higher caps.

### 4. Monetization Strategy
*   **In-App Purchases (IAP)**: Purchase premium currency ("Gold Bars" or "Greasy Favors") to speed up time, buy exclusive characters, or purchase unique visual skins.
*   **Rewarded Ads**: Watch an ad to optionally double offline earnings, get a temporary 2x grow speed boost, or bribe a cop during a raid.

## Development Setup

```bash
# Clone the repository (Private)
git clone https://github.com/imrightguy/WeedEmpire.git

# Install dependencies
flutter pub get

# Run on Linux/macOS/Windows desktops
flutter run -d linux

# Run on a connected mobile device or emulator
flutter run -d <device_id>
```
