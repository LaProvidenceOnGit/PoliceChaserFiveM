# Police Chase Script

This script simulates a high-speed police chase in a game environment, allowing players to experience a thrilling pursuit with customizable difficulty levels. It spawns a police vehicle and driver, who will chase the player based on the selected difficulty. The chase includes immersive visual and audio effects to enhance the experience.

---

## Features

- **Dynamic Difficulty Levels**: Choose from `easy`, `medium`, or `hard` to adjust the speed and aggression of the police.
- **Realistic Police Behavior**: The police driver uses advanced driving techniques to pursue the player.
- **Immersive Effects**: Includes sirens, radio chatter, and cinematic effects to increase immersion.
- **Escape and Capture Mechanics**: The chase ends if the player is caught or successfully escapes.
- **Customizable Police Vehicle**: The police car is equipped with upgrades and visual extras.

---

## Usage

### Commands

- **Start a Chase**: Use the `/chase` command followed by the desired difficulty level (`easy`, `medium`, or `hard`).
  ```plaintext
  /chase medium
  ```
  This will start a police chase with medium difficulty.

- **Reset the Chase**: Use the `/reset` command to stop the current chase and remove all spawned entities.
  ```plaintext
  /reset
  ```

### Difficulty Settings

- **Easy**: The police car has moderate speed and power.
- **Medium**: The police car is faster and more aggressive.
- **Hard**: The police car is extremely fast and highly aggressive.

### In-Game Messages

The script provides real-time feedback through in-game messages, such as:

- `Police approaching! Chase starts in 3 seconds...`
- `You’ve escaped the police! Silence falls...`
- `You've been caught by the police! Sirens blaring...`

---

## Script Details

### Key Functions

- **`SpawnPoliceCar()`**: Spawns the police vehicle and driver, sets up the vehicle's appearance, and prepares for the chase.
- **`StartChase(difficulty)`**: Initiates the chase with the specified difficulty settings.
- **`EndChase(message)`**: Ends the chase and displays the result message.
- **`ResetChase()`**: Cleans up the chase by removing the police vehicle, driver, and blip.

### Utility Functions

- **`LoadModel(modelHash)`**: Ensures the specified model is loaded before spawning.
- **`ShowMessageInGame(message)`**: Displays a message on the player's screen.

### Configuration

The `difficultySettings` table allows you to customize the behavior of the police chase:

```lua
local difficultySettings = {
    easy = {speed = 50.0, power = 15.0, style = 787083},
    medium = {speed = 70.0, power = 30.0, style = 787083},
    hard = {speed = 160.0, power = 120.0, style = 787083}
}
```

- **`speed`**: The base speed of the police vehicle.
- **`power`**: The engine power multiplier.
- **`style`**: The driving style of the police driver.

---

## Requirements

- A game environment that supports Lua scripting (e.g., FiveM for GTA V).
- The necessary game assets (e.g., police car model, driver model).

---

## Installation

1. Place the script in the appropriate directory for your game/modding platform.
2. Ensure the script is loaded and executed by the game engine.
3. Use the provided commands to start and manage the police chase.

---

## Notes

- The script assumes the player is in a vehicle during the chase.
- Adjust the `difficultySettings` to balance the gameplay experience.
- Ensure all required models and sounds are available in the game environment.

---

## License

This script is provided as-is. Feel free to modify and distribute it as needed.

---

Enjoy the thrill of the chase! 🚔💨
