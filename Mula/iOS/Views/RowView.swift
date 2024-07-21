//
//  RowView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct RowView<Content: View>: View {
    let iconName: String
    let title: String
    let color: Color
    let value: () -> Content

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(color)
                .imageScale(.large)
            Text(title)
                .font(.headline)
            Spacer()

            value()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(backgroundCornerRadius)
    }
}

#Preview {
    RowView(iconName: "doc.text", title: "Title:", color: .purple) {
        Text("Popeyes")
    }
}
