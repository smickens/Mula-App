//
//  SearchBarView.swift
//  Mula
//
//  Created by Shanti Mickens on 8/2/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(searchText.isEmpty ? grayAccentColor : activeSearchColor)

            TextField("Search", text: $searchText)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(grayAccentColor)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            searchText = ""
                        }
                    , alignment: .trailing
                )
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(grayBackgroundColor)
                .shadow(
                    color: grayAccentColor.opacity(0.15),
                    radius: 10,
                    x: 0,
                    y: 0
                )
        )
        .padding()
    }

    private var grayBackgroundColor: Color {
        return Color(.systemGray)
    }

    private var grayAccentColor: Color {
        return Color(.systemGray)
    }

    private var activeSearchColor: Color {
        return .indigo
    }
}

#Preview {
    SearchBarView(searchText: .constant("some text"))
}
