# Hedge Runner

A 3D infinite runner game built with Godot 3.x, featuring a unique mathematical gameplay mechanic.

## Game Concept

Hedge Runner is an infinite runner where you control a group of hedgehogs running forward through an endless track. The unique twist: your "strength" is represented by the number of hedgehogs in your group, and obstacles have mathematical operations that modify this count!

## Unique Features

### Mathematical Operations System
- **Obstacles** have mathematical operations (+, -, ×, ÷) that affect your hedgehog count
- Example: Hit a "+4" obstacle with 7 hedgehogs → you now have 11 hedgehogs
- Example: Hit a "×2" obstacle with 5 hedgehogs → you now have 10 hedgehogs

### Visual Magnitude Representation
- Hedgehogs are displayed in groups with different colors representing magnitudes:
  - **Brown**: Ones (1s place)
  - **Blue**: Tens (10s place)
  - **Yellow**: Hundreds (100s place)
  - **Red**: Thousands (1000s place)
- If you have 23 hedgehogs, you'll see 2 blue hedgehogs and 3 brown hedgehogs

### Pointer-Based Controls
- Move your mouse/pointer left or right across the screen
- Your hedgehog group automatically moves to the corresponding lane
- Three lanes to navigate between

## Game Flow

1. **Loading State**: Game serves as a visual loading indicator for a query engine
2. **Auto-start**: Game begins automatically when loaded
3. **Infinite Running**: Hedgehogs run forward continuously
4. **Collect & Dodge**: Collect golden rings for points, dodge/use obstacles strategically
5. **Instant Save**: When loading completes, game state saves to local storage and unloads immediately

## Controls

- **Mouse/Touch**: Move pointer left/right to change lanes
- That's it! Super simple controls

## Technical Architecture

### Core Systems

#### Autoload Singletons
- **GameManager**: Handles game state (loading, running, paused, game over, unloading)
- **ScoreManager**: Tracks score, distance, hedgehog count, and math operations
- **StorageManager**: Saves/loads game state to local storage (web) or file (desktop)

#### Player System
- **HedgehogGroup**: Main player controller managing multiple hedgehog instances
- **Hedgehog**: Individual hedgehog visual representation
- Dynamic hedgehog spawning based on count and magnitude breakdown

#### Generation Systems
- **TrackGenerator**: Infinite track segment generation with object pooling
- **ObstacleSpawner**: Lane-based obstacle spawning with math operations
- **CollectibleSpawner**: Golden ring collectible spawning

#### UI
- **HUD**: Displays score, distance, hedgehog count, and magnitude breakdown

### File Structure

```
hedge-runner/
├── scenes/
│   ├── main/              # Main game scene and logic
│   ├── player/            # Hedgehog and HedgehogGroup scenes
│   ├── obstacles/         # Obstacle scenes with math operations
│   ├── collectibles/      # Collectible items (rings)
│   ├── environment/       # Track segments
│   └── ui/                # HUD and UI screens
├── scripts/
│   ├── autoload/          # Singleton systems (GameManager, etc.)
│   ├── player/            # Player controller logic
│   ├── generation/        # Track, obstacle, collectible spawners
│   ├── obstacles/         # Obstacle behavior and math operations
│   ├── collectibles/      # Collectible behavior
│   └── utils/             # Constants and helper functions
├── assets/
│   ├── models/hedgehog/   # Place African Pygmy Hedgehog asset here
│   └── ...                # Other asset folders
└── resources/             # Materials, shaders, themes

```

## Setup Instructions

### Prerequisites
- Godot 3.x (tested with 3.5+)
- For web builds: Godot HTML5 export templates

### Opening the Project
1. Open Godot Engine
2. Click "Import"
3. Navigate to the `project.godot` file
4. Click "Import & Edit"

### Adding the Hedgehog Asset
1. Download the [African Pygmy Hedgehog](https://godotmarketplace.com/shop/african-pygmy-hedgehog/) asset
2. Extract to `assets/models/hedgehog/`
3. Update `scenes/player/Hedgehog.tscn` to use the actual model instead of placeholder sphere

### Running the Game

#### Desktop
- Press F5 or click the "Play" button in Godot

#### Web Export
1. Go to Project → Export
2. Select "HTML5" preset
3. Click "Export Project"
4. Choose output location (default: `build/web/index.html`)
5. Serve the exported files with a local web server

## Integration with Query Engine

The game is designed to run as a loading state for a query engine:

### JavaScript Integration

```javascript
// When loading starts
window.loadHedgeRunner = function() {
  // Load the Godot game iframe/embed
  // Game auto-starts
}

// When query completes
window.notifyLoadingComplete = function() {
  // Call the game's loading complete handler
  // This can be done via JavaScript interface
  if (window.godotGame) {
    window.godotGame.onLoadingComplete();
  }
}
```

### Godot Side

The `GameManager.on_loading_complete()` function:
1. Saves current game state to local storage
2. Sets state to UNLOADING
3. Signals that it's ready to be removed from the DOM

## Game Constants

Edit `scripts/utils/Constants.gd` to adjust:
- Track width and lane count
- Player speed
- Hedgehog display settings
- Math operation ranges
- Obstacle spawn rates
- Colors for different magnitudes

## Scoring System

- **Distance**: Automatically adds points as you run
- **Collectibles**: Rings worth 10 points each
- **High Scores**: Saved to local storage
- **Stats Tracked**: High score, longest distance, maximum hedgehogs

## Future Enhancements

### Planned Features
- [ ] Sound effects and background music
- [ ] Particle effects for collisions and collections
- [ ] More obstacle types (moving, rotating, etc.)
- [ ] Power-ups (shield, magnet, multiplier)
- [ ] Difficulty progression over time
- [ ] Leaderboard integration
- [ ] 3D labels showing math operations on obstacles
- [ ] Better visual feedback for magnitude changes

### Asset Integration
- [ ] Replace placeholder hedgehog with marketplace asset
- [ ] Add obstacle models (trees, rocks, logs)
- [ ] Create track textures and materials
- [ ] Add environment props (clouds, scenery)

## Development Notes

### Built With
- **Engine**: Godot 3.x
- **Language**: GDScript
- **Rendering**: GLES2 (for better web compatibility)
- **Target Platform**: Web (HTML5) primarily

### Performance Considerations
- Object pooling for track segments
- Limited visual hedgehog count (max 20 per magnitude)
- Efficient collision detection using physics layers
- Automatic cleanup of off-screen objects

## License

[Add your license information here]

## Credits

- African Pygmy Hedgehog model: [Godot Marketplace](https://godotmarketplace.com/shop/african-pygmy-hedgehog/)
- Game developed with Claude Code
