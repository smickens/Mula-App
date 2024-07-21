//
//  RowView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct RowView: View {
    let iconName: String
    let title: String
    let color: Color

    // expect one to be non-nil
    let value: Double?
    let text: String?

    init(iconName: String, title: String, color: Color, value: Double? = nil, text: String? = nil) {
        self.iconName = iconName
        self.title = title
        self.color = color
        self.value = value
        self.text = text
    }

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(color)
                .imageScale(.large)
            Text(title)
                .font(.headline)
            Spacer()
            if let value {
                Text(value, format: .currency(code: "USD"))
                    .font(.body)
            } else if let text {
                Text(text)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(backgroundCornerRadius)
    }
}

#Preview {
    RowView(iconName: "doc.text", title: "Title:", color: .purple, text: "Popeyes")
}
