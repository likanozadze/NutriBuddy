//
//  AppTextField.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/31/25.
//

import SwiftUI

struct AppTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var style: FieldStyle = .regular
    var debounceTime: TimeInterval? = nil
    var onTextChanged: ((String) -> Void)? = nil
    
    @State private var debounceTask: Task<Void, Never>?
    @State private var internalText: String = ""
    @State private var isFirstAppear = true

    enum FieldStyle {
        case regular
        case compact
    }

    var body: some View {
        VStack(alignment: .leading, spacing: style == .compact ? 4 : 6) {
            if style == .regular {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondaryText)
                    .textCase(.uppercase)
            } else {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                    .textCase(.uppercase)
            }

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.customBlue)
                    .frame(width: 20)

                TextField(placeholder, text: $internalText)
                    .keyboardType(keyboardType)
                    .foregroundColor(.primaryText)
                    .onChange(of: internalText) { oldValue, newValue in
                    
                        if !isFirstAppear {
                            handleTextChange(newValue)
                        }
                    }
            }
            .padding(.vertical, style == .compact ? 8 : 12)
            .padding(.horizontal, style == .compact ? 12 : 16)
            .background(Color.listBackground.opacity(style == .compact ? 0.5 : 1))
            .cornerRadius(8)
        }
        .onAppear {
        
            if internalText != text {
                internalText = text
            }
            isFirstAppear = false
        }
        .onChange(of: text) { oldValue, newValue in

            if internalText != newValue {
                internalText = newValue
            }
        }
        .onDisappear {
    
            debounceTask?.cancel()
        }
    }

    private func handleTextChange(_ newValue: String) {

        debounceTask?.cancel()
        
      
        text = newValue
        

        if let debounceTime = debounceTime, let onTextChanged = onTextChanged {
            debounceTask = Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(debounceTime * 1_000_000_000))
                    if !Task.isCancelled {
                        await MainActor.run {
                            onTextChanged(newValue)
                        }
                    }
                } catch {
           
                }
            }
        } else {
          
            onTextChanged?(newValue)
        }
    }
}
