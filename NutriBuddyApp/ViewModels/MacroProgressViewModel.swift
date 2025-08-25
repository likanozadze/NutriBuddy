//
//  MacroProgressViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import SwiftUI

@MainActor
class MacroProgressViewModel: ObservableObject {
    @Published private(set) var macros: [MacroProgress] = []
    
    func updateMacros(_ newMacros: [MacroProgress]) {
        macros = newMacros
    }
}
