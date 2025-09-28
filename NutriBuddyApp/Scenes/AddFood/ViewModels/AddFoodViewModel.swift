//
//  AddFoodViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//
//
import SwiftUI
import SwiftData
import AVFoundation

enum NutritionInputMode: String, CaseIterable {
    case grams = "Grams"
    case servings = "Servings"
    
    var displayName: String {
        switch self {
        case .servings: return "Servings"
        case .grams: return "Grams"
        }
    }
    
    var icon: String {
        switch self {
        case .servings: return "number.circle"
        case .grams: return "scalemass"
        }
    }
}

final class AddFoodViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var inputMode: NutritionInputMode = .grams
    @Published var showAdvancedOptions = false
    @Published var selectedTab: AddFoodTab = .quickAdd
    
    // Barcode-related properties
    @Published var showingBarcodeScanner = false
    @Published var showingBarcodeResult = false
    @Published var scannedBarcodeFood: BarcodeFood?
    @Published var isLoadingBarcodeFood = false
    @Published var barcodeError: String?
    @Published var showingBarcodeError = false
    @Published var processingBarcode: String?
    @Published var loadingMessage = "Looking up product..."
    
    @Published var servingAmount = ""
    @Published var servingCalories = ""
    @Published var servingProtein = ""
    @Published var servingCarbs = ""
    @Published var servingFat = ""
    @Published var servingFiber = ""
    @Published var servingSugar = ""
    
    @Published var caloriesPer100g = ""
    @Published var proteinPer100g = ""
    @Published var carbsPer100g = ""
    @Published var fatPer100g = ""
    @Published var fiberPer100g = ""
    @Published var sugarPer100g = ""
    @Published var grams = ""
    
    @Published var uniqueFoodTemplates: [RecentFood] = []
    @Published var searchResults: [FoodSearchResult] = []
    @Published var isSearching = false

    let selectedDate: Date
    private var context: ModelContext
    private let foodSearchService = FoodSearchService()
    private let barcodeService = BarcodeFoodService()
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self.context = context
    }
    
    // MARK: - Computed Properties for View
  var isValidForm: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        
        switch inputMode {
        case .servings:
            return isValidDouble(servingAmount) && isValidPositiveDouble(servingAmount) &&
                   isValidDouble(servingCalories) && isValidNonNegativeDouble(servingCalories)
            
        case .grams:
          
            return isValidDouble(caloriesPer100g) && isValidNonNegativeDouble(caloriesPer100g) &&
                   isValidDouble(grams) && isValidPositiveDouble(grams)
        }
    }

    private func safeDoubleValue(_ string: String) -> Double {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? 0.0 : (Double(trimmed) ?? 0.0)
    }

    var calculatedProtein: Double {
        switch inputMode {
        case .servings:
            let prot = safeDoubleValue(servingProtein)
            guard let amount = Double(servingAmount), amount > 0 else { return 0 }
            return prot * amount
        case .grams:
            let prot = safeDoubleValue(proteinPer100g)
            guard let gr = Double(grams), gr > 0 else { return 0 }
            return (prot * gr) / 100
        }
    }
    

    var calculatedCalories: Double {
        switch inputMode {
        case .servings:
            guard let cal = Double(servingCalories), cal >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return cal * amount
        case .grams:
            guard let cal = Double(caloriesPer100g), cal >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (cal * gr) / 100
        }
    }
    
    
    var calculatedCarbs: Double {
        switch inputMode {
        case .servings:
            guard let carbs = Double(servingCarbs), carbs >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return carbs * amount
        case .grams:
            guard let carbs = Double(carbsPer100g), carbs >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (carbs * gr) / 100
        }
    }
    
    var calculatedFat: Double {
        switch inputMode {
        case .servings:
            guard let fat = Double(servingFat), fat >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return fat * amount
        case .grams:
            guard let fat = Double(fatPer100g), fat >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (fat * gr) / 100
        }
    }
    
    var calculatedFiber: Double {
        switch inputMode {
        case .servings:
            guard let fiber = Double(servingFiber), fiber >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return fiber * amount
        case .grams:
            guard let fiber = Double(fiberPer100g), fiber >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (fiber * gr) / 100
        }
    }
    
    var calculatedSugar: Double {
        switch inputMode {
        case .servings:
            guard let sugar = Double(servingSugar), sugar >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return sugar * amount
        case .grams:
            guard let sugar = Double(sugarPer100g), sugar >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (sugar * gr) / 100
        }
    }

    // MARK: - Barcode Scanning Methods
    func handleScanTapped() {
        checkCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.showingBarcodeScanner = true
                }
            }
        }
    }
    
    func handleBarcodeScanned(_ barcode: String) {
        showingBarcodeScanner = false
        
        guard processingBarcode != barcode else {
            print("🔄 Already processing barcode: \(barcode)")
            return
        }
        
        print("🔍 Barcode scanned in AddFoodView: \(barcode)")
        processingBarcode = barcode
        isLoadingBarcodeFood = true
        scannedBarcodeFood = nil
        loadingMessage = "Looking up product..."
        
        Task {
            await fetchBarcodeFood(barcode: barcode)
        }
    }
    
    func cancelBarcodeScanning() {
        showingBarcodeScanner = false
    }
    
    func saveBarcodeFood(grams: Double) {
        guard let barcodeFood = scannedBarcodeFood else { return }
        addBarcodeFood(barcodeFood, grams: grams)
        scannedBarcodeFood = nil
        showingBarcodeResult = false
    }
    
    func cancelBarcodeResult() {
        scannedBarcodeFood = nil
        showingBarcodeResult = false
    }
    
    func dismissBarcodeError() {
        barcodeError = nil
        showingBarcodeError = false
    }
    
    
    // MARK: - Private Barcode Methods
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.barcodeError = "Camera access is required to scan barcodes. Please enable camera access in Settings."
                self?.showingBarcodeError = true
            }
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func fetchBarcodeFood(barcode: String) async {
        print("📡 Starting API lookup for: \(barcode)")
        
        do {
            if let barcodeFood = await barcodeService.fetchFoodInfo(barcode: barcode) {
                print("✅ Successfully fetched food data: \(barcodeFood.name)")
                await MainActor.run { [weak self] in
                    self?.isLoadingBarcodeFood = false
                    self?.scannedBarcodeFood = barcodeFood
                    self?.showingBarcodeResult = true
                    self?.processingBarcode = nil
                    print("🔄 UI updated with barcode food")
                }
            } else {
                print("❌ Failed to fetch food data for barcode: \(barcode)")
                await MainActor.run { [weak self] in
                    self?.isLoadingBarcodeFood = false
                    self?.processingBarcode = nil
                    self?.barcodeError = "Product not found in database. Please try manual entry or scan a different product."
                    self?.showingBarcodeError = true
                }
            }
        }
    }
    
    private func addBarcodeFood(_ barcodeFood: BarcodeFood, grams: Double) {
        let food = FoodEntry(
            name: barcodeFood.name,
            caloriesPer100g: barcodeFood.caloriesPer100g,
            proteinPer100g: barcodeFood.proteinPer100g,
            carbsPer100g: barcodeFood.carbsPer100g,
            fatPer100g: barcodeFood.fatPer100g,
            fiberPer100g: barcodeFood.fiberPer100g,
            sugarPer100g: barcodeFood.sugarPer100g,
            grams: grams,
            date: selectedDate,
            inputMode: NutritionInputMode.grams.rawValue
        )
        
        saveFood(food)
        print("💾 Successfully saved barcode food to database")
    }

    // MARK: - Public Methods
    @MainActor
    func loadFoodTemplates() async {
        do {
            let descriptor = FetchDescriptor<FoodEntry>()
            let allFoods = try context.fetch(descriptor)
            self.uniqueFoodTemplates = await generateFoodTemplates(from: allFoods)
        } catch {
            print("Failed to load food templates: \(error)")
            self.uniqueFoodTemplates = []
        }
    }
    
    func searchFoods(searchText: String) async {
        if searchText.isEmpty {
            await MainActor.run {
                searchResults = uniqueFoodTemplates.map { .local($0) }
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
        }
        
        let localResults = uniqueFoodTemplates
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .map { FoodSearchResult.local($0) }
        
        let apiResults = await foodSearchService.searchFoods(query: searchText)
            .map { FoodSearchResult.api($0) }

        await MainActor.run {
            searchResults = localResults + apiResults
            isSearching = false
        }
    }
    
    func getFilteredFoodTemplates(searchText: String) -> [RecentFood] {
        if searchText.isEmpty {
            return uniqueFoodTemplates
        }
        return uniqueFoodTemplates.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func addQuickFood(_ template: RecentFood) {
        let food = FoodEntry(
            name: template.name,
            caloriesPer100g: template.caloriesPer100g,
            proteinPer100g: template.proteinPer100g,
            carbsPer100g: template.carbsPer100g,
            fatPer100g: template.fatPer100g,
            fiberPer100g: template.fiberPer100g,
            sugarPer100g: template.sugarPer100g,
            grams: template.servingSize ?? 100,
            date: selectedDate,
            inputMode: template.inputMode,
            servingSize: template.isServingMode ? (template.servingSize ?? 100) : nil
        )
        
        saveFood(food)
    }
    
    func addAPIFood(_ apiFood: APIFood, grams: Double) {
        let food = FoodEntry(
            name: apiFood.name,
            caloriesPer100g: apiFood.caloriesPer100g,
            proteinPer100g: apiFood.proteinPer100g,
            carbsPer100g: apiFood.carbsPer100g,
            fatPer100g: apiFood.fatPer100g,
            fiberPer100g: apiFood.fiberPer100g,
            sugarPer100g: apiFood.sugarPer100g,
            grams: grams,
            date: selectedDate,
            inputMode: NutritionInputMode.grams.rawValue
        )
        
        saveFood(food)
    }
    
    func saveFood() {
        let food = createFoodEntry()
        saveFood(food)
    }
    
    private func createFoodEntry() -> FoodEntry {
        switch inputMode {
        case .servings:
            let servCal = Double(servingCalories) ?? 0
            let servProt = safeDoubleValue(servingProtein)
            let amount = Double(servingAmount) ?? 1
            
            let totalGrams = amount * 100
            
            return FoodEntry(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                caloriesPer100g: servCal,
                proteinPer100g: servProt,
                carbsPer100g: safeDoubleValue(servingCarbs),
                fatPer100g: safeDoubleValue(servingFat),
                fiberPer100g: safeDoubleValue(servingFiber),
                sugarPer100g: safeDoubleValue(servingSugar),
                grams: totalGrams,
                date: selectedDate,
                inputMode: inputMode.rawValue,
                servingSize: 100
            )
            
        case .grams:
            return FoodEntry(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                caloriesPer100g: Double(caloriesPer100g) ?? 0,
                proteinPer100g: safeDoubleValue(proteinPer100g),
                carbsPer100g: safeDoubleValue(carbsPer100g),
                fatPer100g: safeDoubleValue(fatPer100g),
                fiberPer100g: safeDoubleValue(fiberPer100g),
                sugarPer100g: safeDoubleValue(sugarPer100g),
                grams: Double(grams) ?? 0,
                date: selectedDate,
                inputMode: inputMode.rawValue
            )
        }
    }
    // MARK: - Private Methods
    private func generateFoodTemplates(from foods: [FoodEntry]) async -> [RecentFood] {
        return await Task.detached {
            let grouped = Dictionary(grouping: foods) { food in
                "\(food.name)-\(food.caloriesPer100g)-\(food.proteinPer100g)-\(food.carbsPer100g)-\(food.fatPer100g)"
            }
            return grouped.compactMap { _, foods in
                guard let first = foods.first else { return nil }
                let totalEntries = foods.count
                let lastUsed = foods.max(by: { $0.date < $1.date })?.date ?? .distantPast
                return RecentFood(
                    name: first.name,
                    caloriesPer100g: first.caloriesPer100g,
                    proteinPer100g: first.proteinPer100g,
                    carbsPer100g: first.carbsPer100g,
                    fatPer100g: first.fatPer100g,
                    fiberPer100g: first.fiberPer100g,
                    sugarPer100g: first.sugarPer100g,
                    inputMode: first.inputMode,
                    servingSize: first.servingSize,
                    timesUsed: totalEntries,
                    lastUsed: lastUsed
                )
            }
            .sorted { $0.lastUsed > $1.lastUsed }
        }.value
    }
    

    private func saveFood(_ food: FoodEntry) {
        context.insert(food)
        
        do {
            try context.save()
        } catch {
            print("Failed to save food: \(error)")
        }
    }
    
    // MARK: - Validation Helpers
    private func isValidDouble(_ string: String) -> Bool {
        return Double(string) != nil
    }
    
    private func isValidPositiveDouble(_ string: String) -> Bool {
        guard let value = Double(string) else { return false }
        return value > 0
    }
    
    private func isValidNonNegativeDouble(_ string: String) -> Bool {
        guard let value = Double(string) else { return false }
        return value >= 0
    }
    
    
}

// MARK: - Barcode Food Validation
extension AddFoodViewModel {
    func validateBarcodeFood(_ barcodeFood: BarcodeFood) -> Bool {
        return !barcodeFood.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               barcodeFood.caloriesPer100g >= 0 &&
               barcodeFood.proteinPer100g >= 0
    }
}
