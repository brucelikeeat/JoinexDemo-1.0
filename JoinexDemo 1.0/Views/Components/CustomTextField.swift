//
//  CustomTextField.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

// Custom placeholder color modifier
struct PlaceholderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.gray.opacity(0.95))
    }
}

extension View {
    func placeholderStyle() -> some View {
        modifier(PlaceholderStyle())
    }
}

struct CustomTextField: View {
    let label: String
    let placeholder: String
    let icon: String?
    let text: Binding<String>
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    
    @State private var isPasswordVisible = false
    @FocusState private var isFocused: Bool
    
    init(label: String, placeholder: String, text: Binding<String>, icon: String? = nil, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.label = label
        self.placeholder = placeholder
        self.text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.black)
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
                
                if isSecure {
                    Group {
                        if isPasswordVisible {
                            TextField(placeholder, text: text)
                                .foregroundColor(.black)
                                .accentColor(.royalBlue)
                                .placeholderStyle()
                        } else {
                            SecureField(placeholder, text: text)
                                .foregroundColor(.black)
                                .accentColor(.royalBlue)
                                .placeholderStyle()
                        }
                    }
                    .keyboardType(keyboardType)
                    .focused($isFocused)
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                } else {
                    TextField(placeholder, text: text)
                        .foregroundColor(.black)
                        .accentColor(.royalBlue)
                        .placeholderStyle()
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                }
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.royalBlue : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            label: "Email",
            placeholder: "john.doe@example.com",
            text: .constant(""),
            icon: "envelope"
        )
        
        CustomTextField(
            label: "Password",
            placeholder: "Enter your password",
            text: .constant(""),
            icon: "lock",
            isSecure: true
        )
        
        CustomTextField(
            label: "Username",
            placeholder: "Enter username",
            text: .constant("brucelikeeat")
        )
    }
    .padding()
} 