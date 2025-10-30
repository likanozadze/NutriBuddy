# NutriBuddy

A lightweight, simple macronutrient tracking app built with SwiftUI. Track your calories, protein, carbs, fats, and fiber with three flexible input methods: manual entry, barcode scanning, or food database lookup.

## Why NutriBuddy?

NutriBuddy was born from a personal fitness journey. When you're just starting your fitness goals, you don't need a bloated app—you need something simple that works. What started as a template in Apple Numbers became a full-featured tracking app focused on simplicity and core functionality.

Unlike feature-heavy alternatives, NutriBuddy does one thing well: tracking your nutrition toward your goals. No unnecessary social features, no ads, just straightforward macro tracking.

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

## Clone the project

