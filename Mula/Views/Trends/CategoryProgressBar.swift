//
//  CategoryProgressBar.swift
//  Mula
//
//  Created by Shanti Mickens on 2/24/26.
//

import SwiftUI

struct CategoryProgressBar: View {
    let percentage: Double
    let color: Color
    var height: CGFloat
    let displayTrack: Bool = false

    @State private var animatedValue: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                // Track
                if displayTrack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: height)
                }

                // Fill
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.9),
                                    color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * animatedValue,
                            height: height
                        )

                    Text("\(percentageText)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .leading)
                }

            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedValue = percentage
            }
        }
    }

    private var percentageText: Int {
        Int((percentage * 100).rounded())
    }
}
