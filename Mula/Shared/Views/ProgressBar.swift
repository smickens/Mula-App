//
//  ProgressBar.swift
//  Mula
//
//  Created by Shanti Mickens on 6/15/24.
//

import SwiftUI

struct ProgressBar: View {
    let barCornerRadius: CGFloat = 5.0
    let barHeight: CGFloat = 15.0
    
    let target: CGFloat
    let totalSpent: CGFloat
    let overBudget: Bool
    let progress: CGFloat
    let barColor: Color
    
    init(target: CGFloat, totalSpent: CGFloat, barColor: Color) {
        self.target = target
        self.totalSpent = totalSpent
        let percentage = target != 0.0 ? totalSpent / target : (totalSpent > 0.0 ? 1.0 : 0.0)
        self.overBudget = percentage > 1.0
        self.progress = overBudget ? target / totalSpent : percentage
        self.barColor = barColor
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {            
//            Text(totalSpent, format: .currency(code: "USD")) + Text(" of ") + Text(target, format: .currency(code: "USD"))
            HStack {
                Text(totalSpent, format: .currency(code: "USD"))
                
                Spacer()
                
                Text("\(overBudget ? "Over" : "Under") ") + Text(abs(totalSpent - target), format: .currency(code: "USD"))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: barCornerRadius)
                        .frame(width: geometry.size.width)
                        .opacity(0.3)
                        .foregroundColor(overBudget ? Color.red : Color.gray)
                    
                    RoundedRectangle(cornerRadius: barCornerRadius)
                        .frame(width: min(progress * geometry.size.width, geometry.size.width))
                        .foregroundColor(barColor)
                        .animation(.linear(duration: 0.3), value: progress)  // Animation for smooth progress change
                }
            }
            .frame(height: barHeight)
        }
    }
}
