//
//  DatePeriodSelector.swift
//  Mula
//
//  Created by Codex on 5/25/26.
//

import SwiftUI

struct DatePeriodSelector: View {
    enum Granularity {
        case month
        case year
    }

    @Binding var selectedDate: Date

    let granularity: Granularity

    @State private var isShowingPicker = false

    var body: some View {
        HStack(spacing: 8) {
            Button {
                moveSelection(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)

            Button {
                isShowingPicker.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")

                    Text(label)
                        .fontWeight(.semibold)

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.title2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isShowingPicker, arrowEdge: .bottom) {
                picker
                    .padding()
                    .frame(width: 320)
            }

            Button {
                moveSelection(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)
        }
    }
}

private extension DatePeriodSelector {
    var label: String {
        let formatter = DateFormatter()

        switch granularity {
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        case .year:
            formatter.dateFormat = "yyyy"
        }

        return formatter.string(from: selectedDate)
    }

    @ViewBuilder
    var picker: some View {
        switch granularity {
        case .month:
            MonthPicker(selectedDate: $selectedDate)
        case .year:
            YearPicker(selectedDate: $selectedDate)
        }
    }

    func moveSelection(by value: Int) {
        let component: Calendar.Component = granularity == .month ? .month : .year
        selectedDate = Calendar.current.date(byAdding: component, value: value, to: selectedDate) ?? Date()
    }
}

private struct MonthPicker: View {
    @Binding var selectedDate: Date

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    private let months = Calendar.current.shortMonthSymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    selectedYear -= 1
                    applySelection()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.borderless)

                Spacer()

                Text(String(selectedYear))
                    .font(.headline)
                    .monospacedDigit()

                Spacer()

                Button {
                    selectedYear += 1
                    applySelection()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.borderless)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...12, id: \.self) { month in
                    Button {
                        selectedMonth = month
                        applySelection()
                    } label: {
                        Text(months[month - 1])
                            .font(.subheadline)
                            .fontWeight(selectedMonth == month ? .semibold : .regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedMonth == month ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                            .foregroundColor(selectedMonth == month ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            selectedMonth = Calendar.current.component(.month, from: selectedDate)
            selectedYear = Calendar.current.component(.year, from: selectedDate)
        }
    }

    private func applySelection() {
        var components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: selectedDate)
        components.year = selectedYear
        components.month = selectedMonth
        components.day = min(components.day ?? 1, daysInSelectedMonth)

        if let date = Calendar.current.date(from: components) {
            selectedDate = date
        }
    }

    private var daysInSelectedMonth: Int {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1

        guard let date = Calendar.current.date(from: components),
              let range = Calendar.current.range(of: .day, in: .month, for: date) else {
            return 28
        }

        return range.count
    }
}

private struct YearPicker: View {
    @Binding var selectedDate: Date

    @State private var visibleStartYear: Int = Calendar.current.component(.year, from: Date()) - 5

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    visibleStartYear -= 12
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.borderless)

                Spacer()

                Text("\(visibleStartYear) - \(visibleStartYear + 11)")
                    .font(.headline)
                    .monospacedDigit()

                Spacer()

                Button {
                    visibleStartYear += 12
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.borderless)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(visibleStartYear..<(visibleStartYear + 12), id: \.self) { year in
                    Button {
                        apply(year: year)
                    } label: {
                        Text(String(year))
                            .font(.subheadline)
                            .fontWeight(year == selectedYear ? .semibold : .regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(year == selectedYear ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                            .foregroundColor(year == selectedYear ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            visibleStartYear = selectedYear - 5
        }
    }

    private var selectedYear: Int {
        Calendar.current.component(.year, from: selectedDate)
    }

    private func apply(year: Int) {
        var components = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: selectedDate)
        components.year = year

        if let date = Calendar.current.date(from: components) {
            selectedDate = date
        }
    }
}
