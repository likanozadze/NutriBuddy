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
    @Query var profiles: [UserProfile]
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
    
    private var currentProfile: UserProfile? {
           profiles.first
       }

       private var caloriesRemaining: Double {
           guard let profile = currentProfile else { return 0 }
           return profile.dailyCalorieTarget - totalCalories
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
           VStack(alignment: .leading, spacing: 8) {
               if let profile = currentProfile {
                   VStack(alignment: .leading, spacing: 4) {
                       Text("Daily Target: \(Int(profile.dailyCalorieTarget)) kcal")
                           .font(.headline)
                       Text("Eaten: \(totalCalories.asCalorieString)")
                           .font(.subheadline)
                           .foregroundStyle(.secondary)
                       Text("Remaining: \(caloriesRemaining.asCalorieString)")
                           .font(.subheadline)
                           .foregroundStyle(caloriesRemaining >= 0 ? .green : .red)
                   }
                   .padding(.horizontal)
               } else {
                   Text("Set up your profile to see your daily target")
                       .font(.subheadline)
                       .foregroundStyle(.secondary)
                       .padding(.horizontal)
               }

               Text("Protein: \(totalProtein.asProteinString)")
                   .font(.subheadline)
                   .foregroundStyle(.secondary)
                   .padding(.horizontal)
           }
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
