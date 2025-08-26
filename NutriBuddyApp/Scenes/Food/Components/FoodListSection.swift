//
//  FoodListSection.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

//import SwiftUI
//import SwiftData
//
//struct FoodListSection: View {
//    let foods: [FoodEntry]
//    let selectedDate: Date
//    let onDelete: (IndexSet) -> Void
//    @State private var showingAddFood = false
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            
//            HStack {
//                HStack(spacing: 8) {
//                    Image(systemName: "fork.knife")
//                        .foregroundColor(.customOrange)
//                        .font(.title3)
//                        .frame(width: 28, height: 28)
//                        .background(Circle().fill(Color.customOrange.opacity(0.1)))
//                    
//                    Text("Food log")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primaryText)
//                }
//                Spacer()
//                
//                Text("\(foods.count) items")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            if foods.isEmpty {
//                EmptyFoodLogView(onAddFood: {
//                    showingAddFood = true
//                })
//                .padding(.vertical, 32)
//            } else {
//                VStack(spacing: 12) {
//                    List {
//                        ForEach(foods, id: \.id) { food in
//                            HStack {
//                                FoodRowView(food: food)
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                            .background(Color(.systemBackground))
//                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                        }
//                        .onDelete(perform: onDelete)
//                    }
//                    .listStyle(.plain)
//                    .frame(minHeight: 100, maxHeight: 300)
//                    
//                    
//                    Button(action: {
//                        showingAddFood = true
//                    }) {
//                        HStack {
//                            Text("Add Food")
//                                .font(.system(size: 16, weight: .medium))
//                        }
//                        .foregroundColor(Color.appBackground)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background(Color.customOrange)
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                    }
//                }
//            }
//        }
//        .background(Color(.systemGroupedBackground).opacity(0.3))
//        .sheet(isPresented: $showingAddFood) {
//            AddFoodView(selectedDate: selectedDate)
//        }
//    }
//}
//
//struct EmptyFoodLogView: View {
//    let onAddFood: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Button(action: {
//                onAddFood()
//            }) {
//                Image(systemName: "plus.circle")
//                    .font(.system(size: 48))
//                    .foregroundColor(.customOrange.opacity(0.6))
//            }
//            .buttonStyle(.plain) 
//            
//            VStack(spacing: 4) {
//                Text("No food logged yet")
//                    .font(.headline)
//                    .foregroundColor(.primaryText)
//                
//                Text("Tap the plus circle to start tracking")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//        }
//    }
//}



import SwiftUI
import SwiftData

struct FoodListSection: View {
    let foods: [FoodEntry]
    let selectedDate: Date
    @Environment(\.modelContext) private var context
    @State private var showingAddFood = false
    
    var body: some View {
        VStack(spacing: 12) {
            
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.customOrange)
                        .font(.title3)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.customOrange.opacity(0.1)))
                    
                    Text("Food log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                }
                Spacer()
                
                Text("\(foods.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if foods.isEmpty {
                EmptyFoodLogView(onAddFood: {
                    showingAddFood = true
                })
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 12) {
                    List {
                        ForEach(foods, id: \.id) { food in
                            HStack {
                                FoodRowView(food: food)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .onDelete(perform: deleteFoods)
                    }
                    .listStyle(.plain)
                    .frame(minHeight: 100, maxHeight: 300)
                    
                    Button(action: {
                        showingAddFood = true
                    }) {
                        HStack {
                            Text("Add Food")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color.appBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.customOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).opacity(0.3))
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(selectedDate: selectedDate)
        }
    }
    
    private func deleteFoods(at offsets: IndexSet) {
        let sortedOffsets = offsets.sorted(by: >)
        
        withAnimation {
            for offset in sortedOffsets {
                guard offset >= 0 && offset < foods.count else { continue }
                let foodToDelete = foods[offset]
                context.delete(foodToDelete)
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to delete foods: \(error)")
            }
        }
    }
}

struct EmptyFoodLogView: View {
    let onAddFood: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                onAddFood()
            }) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.customOrange.opacity(0.6))
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 4) {
                Text("No food logged yet")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text("Tap the plus circle to start tracking")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
