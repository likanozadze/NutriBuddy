

# NutriBuddy

A lightweight, simple macronutrient tracking app built with SwiftUI. Track your calories, protein, carbs, fats, and fiber with three flexible input methods: manual entry, barcode scanning, or food database lookup.

## Why NutriBuddy?

NutriBuddy was born from a personal fitness journey. When you're just starting your fitness goals, you don't need a bloated app—you need something simple that works. What started as a template in Apple Numbers became a full-featured tracking app focused on simplicity and core functionality.

Unlike feature-heavy alternatives, NutriBuddy does one thing well: tracking your nutrition toward your goals. No unnecessary social features, no ads, just straightforward macro tracking.

<img width="400" height="485" alt="Image" src="https://github.com/user-attachments/assets/67bacc5d-01fb-4ca2-9efa-96ebff1bfd66" />

## Features

### 📊 Smart Nutrition Tracking
- **Calorie & Macro Tracking** — Monitor calories, protein, carbs, fats, and fiber
- **Daily Progress Bar** — Visual representation of your remaining calorie budget
- **Macro Overview** — See all nutritional data at a glance with color-coded indicators

### 🍔 Three Ways to Log Food
- **Manual Entry** — Add food items with custom calorie and macro values per 100g
- **Barcode Scanner** — Scan food barcodes instantly for accurate nutrition data (supports EAN-8, EAN-13, UPC-E, Code 128, QR, and more)
- **Food Database API** — Search the USDA FoodData Central database for millions of food items

### 💾 Smart Favorites
- Recently logged foods are saved automatically
- Quick-add previously eaten items without re-entering data
- Adjust portion sizes on the fly

### 🎯 Personalized Goals
- **Onboarding Setup** — Input your gender, height, weight, and activity level
- **Fitness Goal Calculation** — App calculates daily calorie target based on your goals (lose weight, maintain, or gain)
- **Editable Profile** — Update your information anytime to recalculate targets

### 📱 Health Integration
- **HealthKit Integration** — Automatic step tracking from your iPhone
- **Activity Display** — See your daily step count alongside nutrition data

### 💾 Data Persistence
- **SwiftData** — All food logs and profile data stored locally on your device
- Your data stays with you, never synced to external servers

## Tech Stack

- **SwiftUI** — Modern, declarative UI framework
- **SwiftData** — Local data persistence
- **AVFoundation** — Camera and barcode scanning
- **HealthKit** — Step tracking integration
- **USDA FoodData Central API** — Food database

## Requirements

- iOS 15.0 or later
- iPhone (iPad support coming soon)
- Camera permission for barcode scanning
- HealthKit permission (optional, for step tracking)

## Installation

### Building from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/likanozadze/NutriBuddy.git
   ```

2. Open the project in Xcode:
   ```bash
   open NutriBuddy.xcodeproj
   ```

3. Select your target device and press `Cmd + R` to build and run

### Permissions

NutriBuddy requires the following permissions:
- **Camera** — For barcode scanning
- **HealthKit** — For step tracking (optional but recommended)

Add these to your `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan food barcodes.</string>
<key>NSHealthShareUsageDescription</key>
<string>We access your step data to show your daily activity.</string>
```

## Usage

### Getting Started

1. **Complete Onboarding** — Set your profile (gender, height, weight, activity level, fitness goal)
2. **View Daily Target** — See your personalized calorie and macro targets on the home screen
3. **Log Food** — Use any of the three methods to add food items

### Logging Food

**Manual Entry:** Tap the "+" button and select Manual. Enter the food name, amount eaten, and macros per 100g.

**Barcode Scan:** Tap the barcode icon and point your camera at a food barcode. Nutrition data populates automatically.

**Database Search:** Tap the API button to search the USDA database. Adjust portion size and add to your log.

### Track Your Progress

- Watch your daily progress bar update as you log meals
- Check macro breakdowns to ensure you hit your targets
- Review your daily steps integrated from HealthKit

### Update Your Profile

Visit the Profile tab to adjust your information—weight changes, new fitness goals, or updated activity level all automatically recalculate your daily targets.

## Architecture

The app follows a clean, modular structure:

- **Views** — SwiftUI components for UI
- **Models** — Data structures for food items, logs, and user profile
- **Managers** — Services for API calls, barcode scanning, and HealthKit access
- **Database** — SwiftData models for persistence

## Future Enhancements

- iPad support
- Meal presets and recipes
- Weekly/monthly nutrition reports
- Export nutrition data

## Contributing

This is a personal project, but feel free to fork and modify for your own use!

## License

MIT License — feel free to use, modify, and distribute.

## Contact

Created by Lika Nozadze

---

**Ready to simplify your fitness tracking?** Download NutriBuddy and focus on what matters—hitting your nutrition goals.
