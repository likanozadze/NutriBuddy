//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData


struct FoodListView: View {
    @Query private var allFoods: [FoodEntry]
    @State private var selectedDate = Date()
    @Environment(\.modelContext) private var context
    
    private var dailyFoods: [FoodEntry] {
        NutritionCalculator.filterFoodsForDate(allFoods, date: selectedDate)
    }
    
    private var totalCalories: Double {
        NutritionCalculator.calculateTotalCalories(from: dailyFoods)
    }
    
    private var totalProtein: Double {
        NutritionCalculator.calculateTotalProtein(from: dailyFoods)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                datePickerSection
                dailySummarySection
                foodListSection
            }
            .navigationTitle("Nutrition Tracker")
            .toolbar {
                addFoodButton
            }
        }
    }
    
    private var datePickerSection: some View {
        DatePicker("Select day", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.compact)
            .padding()
    }
    
    private var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total: \(totalCalories.asCalorieString)")
                .font(.headline)
            Text("Protein: \(totalProtein.asProteinString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var foodListSection: some View {
        List {
            ForEach(dailyFoods) { food in
                FoodRowView(food: food)
            }
            .onDelete(perform: deleteFoods)
        }
    }
    
    private var addFoodButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink("Add") {
                AddFoodView(selectedDate: selectedDate)
            }
        }
    }
    
    private func deleteFoods(at offsets: IndexSet) {
        offsets.forEach { index in
            context.delete(dailyFoods[index])
        }
        try? context.save()
    }
}
