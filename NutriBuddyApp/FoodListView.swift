//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

struct FoodListView: View {
    @Query var foods: [FoodEntry]
    @State private var selectedDate = Date()
    @Environment(\.modelContext) private var context
    
    var dailyFoods: [FoodEntry] {
        foods.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var totalCalories: Double {
        dailyFoods.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProtein: Double {
        dailyFoods.reduce(0.0) { $0 + $1.totalProtein }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select day",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.automatic)
                .padding()

                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Calories: \(Int(totalCalories)) kcal")
                        .font(.headline)
                    Text("Total Protein: \(totalProtein, specifier: "%.1f") g")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                
                
                List {
                    ForEach(dailyFoods) { food in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.name).font(.headline)
                            Text("\(Int(food.grams)) g → \(Int(food.totalCalories)) kcal, \(food.totalProtein, specifier: "%.1f") g protein")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            deleteFood(dailyFoods[index])
                        }
                    }
                }
            }
            
            .navigationTitle("Today's Foods")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add") {
                        AddFoodView(selectedDate: selectedDate)
                    }
                }
            }
        }
    }
    
    
    func deleteFood(_ food: FoodEntry) {
        context.delete(food)
        try? context.save()
    }
    
}
