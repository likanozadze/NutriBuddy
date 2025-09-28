//
//  FoodCardComponents.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/28/25.
//


import SwiftUI

// MARK: - Food Card Protocol
protocol FoodDisplayable {
    var name: String { get }
    var caloriesPer100g: Double { get }
    var proteinPer100g: Double { get }
    var carbsPer100g: Double { get }
    var fatPer100g: Double { get }
    var brand: String? { get }
}

// MARK: - Make existing types conform to protocol
extension BarcodeFood: FoodDisplayable { }

extension APIFood: FoodDisplayable {
    var brand: String? { nil }
}

extension RecentFood: FoodDisplayable {
    var brand: String? { nil }
}

// MARK: - Reusable Food Information Card
struct FoodInformationCard<Food: FoodDisplayable>: View {
    let food: Food
    let nutritionData: [NutritionInfo]
    let showBaseValues: Bool
    let subtitle: String?
    let customIcon: String?
    @Environment(\.colorScheme) var colorScheme
    
    init(
        food: Food,
        nutritionData: [NutritionInfo],
        showBaseValues: Bool = true,
        subtitle: String? = "Per 100g serving",
        customIcon: String? = nil
    ) {
        self.food = food
        self.nutritionData = nutritionData
        self.showBaseValues = showBaseValues
        self.subtitle = subtitle
        self.customIcon = customIcon
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            UniformNutritionGrid(nutritionData: nutritionData, showBaseValues: showBaseValues)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: 20, x: 0, y: 10)
        )
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(food.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let brand = food.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let iconName = customIcon {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackground)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: iconName)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        )
                        .shadow(color: cardShadow, radius: 5, x: 0, y: 2)
                }
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var cardBackground: some ShapeStyle {
        colorScheme == .dark ?
            AnyShapeStyle(Color(.systemGray5)) :
            AnyShapeStyle(Material.ultraThinMaterial)
    }
    
    private var cardBorder: Color {
        colorScheme == .dark ? Color(.systemGray4) : Color.white.opacity(0.5)
    }
    
    private var cardShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
    }
    
    private var iconBackground: some ShapeStyle {
        colorScheme == .dark ?
            AnyShapeStyle(Color(.systemGray6)) :
            AnyShapeStyle(Material.ultraThinMaterial)
    }
}

// MARK: - Standard Header View
struct StandardHeaderView: View {
    let title: String
    let onCancel: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(buttonBackground)
                            .shadow(color: buttonShadow, radius: 10, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
    }
    
    private var buttonBackground: some ShapeStyle {
        colorScheme == .dark ?
            AnyShapeStyle(Color(.systemGray5)) :
            AnyShapeStyle(Material.ultraThinMaterial)
    }
    
    private var buttonShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
    }
}

// MARK: - Your Portion Preview Card (Fixed for Dark Mode)
struct YourPortionPreviewCard: View {
    let nutritionData: [NutritionInfo]
    let isAnimating: Bool
    @Environment(\.colorScheme) var colorScheme
    
    init(nutritionData: [NutritionInfo], isAnimating: Bool = false) {
        self.nutritionData = nutritionData
        self.isAnimating = isAnimating
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Your Portion")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            UniformNutritionGrid(nutritionData: nutritionData, showBaseValues: false, isAnimating: isAnimating)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: 20, x: 0, y: 10)
        )
    }
    
    private var cardBackground: some ShapeStyle {
        colorScheme == .dark ?
            AnyShapeStyle(Color(.systemGray5)) :
            AnyShapeStyle(Material.ultraThinMaterial)
    }
    
    private var cardBorder: Color {
        colorScheme == .dark ? Color(.systemGray4) : Color.blue.opacity(0.2)
    }
    
    private var cardShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.blue.opacity(0.1)
    }
}

// MARK: - Standard Action Buttons
struct StandardActionButtons: View {
    let onCancel: () -> Void
    let onSave: () -> Void
    let isValidInput: Bool
    let saveButtonText: String
    @Environment(\.colorScheme) var colorScheme
    
    init(
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void,
        isValidInput: Bool,
        saveButtonText: String = "Add Food"
    ) {
        self.onCancel = onCancel
        self.onSave = onSave
        self.isValidInput = isValidInput
        self.saveButtonText = saveButtonText
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(cancelButtonBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(cancelButtonBorder, lineWidth: 1)
                            )
                    )
                    .shadow(color: buttonShadow, radius: 10, x: 0, y: 4)
            }
            
            Button(action: onSave) {
                Text(saveButtonText)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.blue, Color(red: 0.2, green: 0.4, blue: 0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .scaleEffect(isValidInput ? 1.0 : 0.95)
            .opacity(isValidInput ? 1.0 : 0.6)
            .disabled(!isValidInput)
        }
        .padding(.bottom, 20)
    }
    
    private var cancelButtonBackground: some ShapeStyle {
        colorScheme == .dark ?
            AnyShapeStyle(Color(.systemGray5)) :
            AnyShapeStyle(Material.ultraThinMaterial)
    }
    
    private var cancelButtonBorder: Color {
        colorScheme == .dark ? Color(.systemGray4) : Color.white.opacity(0.5)
    }
    
    private var buttonShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
    }
}

// MARK: - Nutrition Data Factory
struct NutritionDataFactory {
    static func createNutritionData<T: FoodDisplayable>(
        for food: T,
        ratio: Double
    ) -> [NutritionInfo] {
        [
            NutritionInfo(
                label: "Calories",
                value: Int(food.caloriesPer100g * ratio),
                baseValue: Int(food.caloriesPer100g),
                unit: nil,
                color: LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                icon: "flame.fill"
            ),
            NutritionInfo(
                label: "Protein",
                value: Int(food.proteinPer100g * ratio),
                baseValue: Int(food.proteinPer100g),
                unit: "g",
                color: LinearGradient(colors: [.blue, Color(red: 0.2, green: 0.4, blue: 0.8)], startPoint: .leading, endPoint: .trailing),
                icon: "bolt.fill"
            ),
            NutritionInfo(
                label: "Carbs",
                value: Int(food.carbsPer100g * ratio),
                baseValue: Int(food.carbsPer100g),
                unit: "g",
                color: LinearGradient(colors: [.green, Color(red: 0.2, green: 0.7, blue: 0.3)], startPoint: .leading, endPoint: .trailing),
                icon: "leaf.fill"
            ),
            NutritionInfo(
                label: "Fat",
                value: Int(food.fatPer100g * ratio),
                baseValue: Int(food.fatPer100g),
                unit: "g",
                color: LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing),
                icon: "drop.fill"
            )
        ]
    }
}

// MARK: - Standard Background View
struct StandardBackgroundView<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundGradient)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    content
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }
    
    private var backgroundGradient: some ShapeStyle {
        if colorScheme == .dark {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemGray5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(.systemGray6).opacity(0.3),
                        Color(.systemGray5).opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

// MARK: - Modern Input Components
struct ModernInputCard: View {
    let icon: String
    let title: String
    let iconColor: Color
    let content: AnyView
    @Environment(\.colorScheme) var colorScheme
    
    init<Content: View>(
        icon: String,
        title: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}
