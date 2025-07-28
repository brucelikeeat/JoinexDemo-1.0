//
//  JoinixLogo.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct JoinixLogo: View {
    let size: CGFloat
    
    init(size: CGFloat = 80) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Blue triangle
            Triangle()
                .fill(Color.blue)
                .frame(width: size, height: size)
            
            // Pink/red curved shape inside triangle
            CurvedShape()
                .fill(Color.pink.opacity(0.8))
                .frame(width: size * 0.5, height: size * 0.375)
                .offset(y: size * 0.0625)
        }
    }
}

// Custom triangle shape for the logo
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Custom curved shape for the logo
struct CurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create a curved shape that resembles a stylized "A" or wave
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.8))
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.2),
            control1: CGPoint(x: width * 0.3, y: height * 0.4),
            control2: CGPoint(x: width * 0.4, y: height * 0.3)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.8),
            control1: CGPoint(x: width * 0.6, y: height * 0.3),
            control2: CGPoint(x: width * 0.7, y: height * 0.4)
        )
        
        return path
    }
}

#Preview {
    JoinixLogo()
} 