//
//  AnimatedButton.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct AnimatedButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let isEnabled: Bool
    
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonOpacity: Double = 1.0
    
    enum ButtonStyle {
        case primary
        case secondary
        case success
        case danger
    }
    
    init(title: String, style: ButtonStyle = .primary, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Animate button press
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                buttonScale = 0.95
                buttonOpacity = 0.8
            }
            
            // Reset animation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                    buttonScale = 1.0
                    buttonOpacity = 1.0
                }
            }
            
            action()
        }) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .cornerRadius(8)
        }
        .scaleEffect(buttonScale)
        .opacity(buttonOpacity)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonScale)
        .disabled(!isEnabled)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? Color.blue : Color.gray
        case .secondary:
            return Color.white
        case .success:
            return isEnabled ? Color.green : Color.gray
        case .danger:
            return isEnabled ? Color.red : Color.gray
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .success, .danger:
            return Color.white
        case .secondary:
            return Color.blue
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .success, .danger:
            return Color.clear
        case .secondary:
            return Color.blue
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .success, .danger:
            return 0
        case .secondary:
            return 1
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AnimatedButton(title: "Primary Button") {
            print("Primary tapped")
        }
        
        AnimatedButton(title: "Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }
        
        AnimatedButton(title: "Success Button", style: .success) {
            print("Success tapped")
        }
        
        AnimatedButton(title: "Disabled Button", isEnabled: false) {
            print("Disabled tapped")
        }
    }
    .padding()
} 