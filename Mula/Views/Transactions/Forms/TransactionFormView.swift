//
//  TransactionFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import SwiftUI

struct TransactionFormView: View {
    @Environment(DataManager.self) private var dataManager

    private enum Layout {
        static let outerSpacing: CGFloat = 18
        static let outerPadding: CGFloat = 24
        static let cardSpacing: CGFloat = 18
        static let cardPadding: CGFloat = 22
        static let cardCornerRadius: CGFloat = 12
        static let cardStrokeOpacity: Double = 0.06
        static let gridSpacing: CGFloat = 14
        static let actionSpacing: CGFloat = 12
        static let actionTopPadding: CGFloat = 4
        static let datePickerWidth: CGFloat = 280
        static let calendarIconSize: CGFloat = 14
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()

    @State private var state: TransactionFormState
    @State private var errorMessage: String?
    @State private var isShowingDatePicker = false

    let title: String?
    let onSave: (Transaction) -> Void
    let onCancel: (() -> Void)?

    init(
        initialState: TransactionFormState,
        title: String? = nil,
        onSave: @escaping (Transaction) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.title = title
        self.onSave = onSave
        self.onCancel = onCancel
        _state = State(initialValue: initialState)
    }

    init(
        title: String? = nil,
        onSave: @escaping (Transaction) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.init(initialState: TransactionFormState(), title: title, onSave: onSave, onCancel: onCancel)
    }

    init(
        transaction: Transaction,
        title: String? = nil,
        onSave: @escaping (Transaction) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.init(initialState: TransactionFormState(from: transaction), title: title, onSave: onSave, onCancel: onCancel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.outerSpacing) {
            if let title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            formCard

            if let errorMessage {
                TransactionErrorBanner(message: errorMessage)
            }

            actionRow
        }
        .padding(Layout.outerPadding)
    }
}

private extension TransactionFormView {

    var formCard: some View {
        VStack(alignment: .leading, spacing: Layout.cardSpacing) {
            TransactionTypeSelector(selectedType: $state.type)
            Divider()

            Grid(alignment: .leading, horizontalSpacing: Layout.gridSpacing, verticalSpacing: Layout.gridSpacing) {
                if state.type.showsTitleField {
                    TransactionFieldRow(label: "Title") {
                        TextField("Coffee, paycheck, rent...", text: $state.title)
                            .textFieldStyle(.plain)
                    }
                }

                TransactionFieldRow(label: "Amount") {
                    HStack(spacing: 8) {
                        Text("$")
                            .foregroundColor(.secondary)
                            .frame(width: 18, alignment: .leading)

                        TextField("0.00", text: $state.amountString)
                            .textFieldStyle(.plain)
                    }
                }

                if state.type == .expense {
                    TransactionFieldRow(label: "My Share") {
                        HStack(spacing: 8) {
                            Text("$")
                                .foregroundColor(.secondary)
                                .frame(width: 18, alignment: .leading)

                            TextField("Full amount", text: $state.myShareAmountString)
                                .textFieldStyle(.plain)
                        }
                    }
                }

                TransactionFieldRow(label: state.type == .transfer ? "From" : "Account") {
                    sourceAccountField
                }

                TransactionFieldRow(label: state.type == .saving ? "Action" : "Category") {
                    categoryField
                }

                if state.type == .transfer {
                    TransactionFieldRow(label: "To") {
                        destinationAccountField
                    }
                }

                TransactionFieldRow(label: "Date") {
                    dateField
                }
            }
        }
        .padding(Layout.cardPadding)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay {
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(Layout.cardStrokeOpacity), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous))
    }

    var sourceAccountField: some View {
        TransactionMenuField(title: selectedSourceAccountName) {
            ForEach(dataManager.accounts) { account in
                Button(account.name) {
                    state.sourceAccountId = account.id
                }
            }
        }
    }

    var destinationAccountField: some View {
        TransactionMenuField(title: selectedDestinationAccountName) {
            ForEach(dataManager.accounts) { account in
                Button(account.name) {
                    state.destinationAccountId = account.id
                }
            }
        }
    }

    var categoryField: some View {
        switch state.type {
        case .expense:
            return AnyView(
                TransactionMenuField(title: state.expenseCategory.displayName) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        Button(category.displayName) {
                            state.expenseCategory = category
                        }
                    }
                }
            )
        case .income:
            return AnyView(
                TransactionMenuField(title: state.incomeCategory.displayName) {
                    ForEach(IncomeCategory.allCases, id: \.self) { category in
                        Button(category.displayName) {
                            state.incomeCategory = category
                        }
                    }
                }
            )
        case .saving:
            return AnyView(
                TransactionMenuField(title: state.savingCategory.displayName) {
                    ForEach(SavingCategory.allCases, id: \.self) { category in
                        Button(category.displayName) {
                            state.savingCategory = category
                        }
                    }
                }
            )
        case .transfer:
            return AnyView(
                TransactionMenuField(title: state.transferCategory.displayName) {
                    ForEach(TransferCategory.allCases, id: \.self) { category in
                        Button(category.displayName) {
                            state.transferCategory = category
                        }
                    }
                }
            )
        }
    }

    var dateField: some View {
        Button {
            isShowingDatePicker.toggle()
        } label: {
            Text(formattedDate)
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            Image(systemName: "calendar")
                .font(.system(size: Layout.calendarIconSize, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingDatePicker, arrowEdge: .bottom) {
            TransactionDatePickerPopover(
                selectedDate: $state.date,
                isPresented: $isShowingDatePicker,
                width: Layout.datePickerWidth
            )
        }
    }

    var actionRow: some View {
        HStack(spacing: Layout.actionSpacing) {
            Spacer()

            if let onCancel {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .buttonStyle(TransactionActionButtonStyle(kind: .secondary))
            }

            Button("Save") {
                do {
                    let transaction = try state.toTransaction()
                    onSave(transaction)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            .buttonStyle(TransactionActionButtonStyle(kind: .primary))

            Spacer()
        }
        .padding(.top, Layout.actionTopPadding)
    }

    var selectedSourceAccountName: String {
        dataManager.accounts.first(where: { $0.id == state.sourceAccountId })?.name ?? "Select account"
    }

    var selectedDestinationAccountName: String {
        dataManager.accounts.first(where: { $0.id == state.destinationAccountId })?.name ?? "Select account"
    }

    var formattedDate: String {
        Self.dateFormatter.string(from: state.date)
    }
}

private enum TransactionFieldRowLayout {
    static let labelWidth: CGFloat = 92
}

private struct TransactionFieldRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        GridRow {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: TransactionFieldRowLayout.labelWidth, alignment: .leading)

            TransactionFieldSurface {
                content
            }
        }
    }
}

private enum TransactionFieldSurfaceLayout {
    static let minimumHeight: CGFloat = 42
    static let horizontalPadding: CGFloat = 14
    static let verticalPadding: CGFloat = 10
    static let cornerRadius: CGFloat = 10
    static let strokeOpacity: Double = 0.08
}

private struct TransactionFieldSurface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, TransactionFieldSurfaceLayout.horizontalPadding)
            .padding(.vertical, TransactionFieldSurfaceLayout.verticalPadding)
            .frame(maxWidth: .infinity, minHeight: TransactionFieldSurfaceLayout.minimumHeight, alignment: .leading)
            .background(Color(NSColor.textBackgroundColor))
            .overlay {
                RoundedRectangle(cornerRadius: TransactionFieldSurfaceLayout.cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(TransactionFieldSurfaceLayout.strokeOpacity), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: TransactionFieldSurfaceLayout.cornerRadius, style: .continuous))
    }
}

private struct TransactionMenuField<MenuContent: View>: View {
    let title: String
    @ViewBuilder let menuContent: MenuContent

    var body: some View {
        Menu {
            menuContent
        } label: {
            Text(title)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .menuStyle(.borderlessButton)
        .buttonStyle(.plain)
    }
}

private struct TransactionTypeSelector: View {
    private enum Layout {
        static let containerPadding: CGFloat = 4
        static let segmentCornerRadius: CGFloat = 10
        static let containerCornerRadius: CGFloat = 12
        static let verticalPadding: CGFloat = 10
    }

    @Binding var selectedType: TransactionKindType

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TransactionKindType.formSelectableCases) { type in
                Button {
                    selectedType = type
                } label: {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(selectedType == type ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.verticalPadding)
                }
                .buttonStyle(.plain)
                .background {
                    if selectedType == type {
                        RoundedRectangle(cornerRadius: Layout.segmentCornerRadius, style: .continuous)
                            .fill(Color(NSColor.textBackgroundColor))
                            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 1)
                    }
                }
            }
        }
        .padding(Layout.containerPadding)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Layout.containerCornerRadius, style: .continuous))
    }
}

private struct TransactionDatePickerPopover: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Date")
                .font(.headline)

            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()

            HStack {
                Spacer()

                Button("Done") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: width)
    }
}

private struct TransactionErrorBanner: View {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 10
    }

    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.red)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
    }
}

private struct TransactionActionButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case secondary
    }

    private enum Layout {
        static let cornerRadius: CGFloat = 10
        static let horizontalPadding: CGFloat = 18
        static let verticalPadding: CGFloat = 10
        static let shadowRadius: CGFloat = 8
        static let shadowYOffset: CGFloat = 2
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            .background(backgroundColor(configuration: configuration))
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
            .shadow(
                color: shadowColor.opacity(configuration.isPressed ? 0.12 : 0.2),
                radius: configuration.isPressed ? 4 : Layout.shadowRadius,
                y: configuration.isPressed ? 1 : Layout.shadowYOffset
            )
            .opacity(configuration.isPressed ? 0.96 : 1)
    }

    private var foregroundColor: Color {
        switch kind {
        case .primary:
            return .white
        case .secondary:
            return .primary
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .primary:
            return .accentColor
        case .secondary:
            return .clear
        }
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        switch kind {
        case .primary:
            return configuration.isPressed ? Color.accentColor.opacity(0.9) : .accentColor
        case .secondary:
            return Color.primary.opacity(configuration.isPressed ? 0.08 : 0.05)
        }
    }
}
