import SwiftUI

// MARK: - Date formatter

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .none
    return f
}()

// MARK: - Row

struct SubRowView: View {
    let sub: Subscription

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(sub.category.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(sub.category.emoji).font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(sub.name)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("\(sub.category.rawValue) · \(sub.cycle.rawValue)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    // Renewal badge
                    if let label = sub.renewalLabel {
                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(sub.renewalColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(sub.renewalColor.opacity(0.1))
                            .cornerRadius(5)
                    } else if let date = sub.renewalDate {
                        Text(dateFormatter.string(from: date))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(sub.amount.currency)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                if sub.cycle != .monthly {
                    Text("\(sub.monthlyAmount.currency)/mo")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Sheet

struct AddSubSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (Subscription) -> Void

    @State private var name        = ""
    @State private var amount      = ""
    @State private var cycle       = BillingCycle.monthly
    @State private var category    = SubCategory.streaming
    @State private var hasRenewal  = false
    @State private var renewalDate = Date()

    var canAdd: Bool { !name.isEmpty && Double(amount) != nil }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Netflix", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Billing Cycle") {
                    Picker("Cycle", selection: $cycle) {
                        ForEach(BillingCycle.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Renewal Date") {
                    Toggle("Set renewal date", isOn: $hasRenewal)
                    if hasRenewal {
                        DatePicker(
                            "Renews on",
                            selection: $renewalDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Category") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(SubCategory.allCases, id: \.self) { cat in
                            Button {
                                category = cat
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(category == cat ? cat.color : Color(.systemGray5))
                                            .frame(width: 44, height: 44)
                                        Text(cat.emoji).font(.system(size: 22))
                                    }
                                    Text(cat.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(category == cat ? cat.color : .secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let amt = Double(amount), amt > 0 else { return }
                        let sub = Subscription(
                            name: name,
                            category: category,
                            amount: amt,
                            cycle: cycle,
                            renewalDate: hasRenewal ? renewalDate : nil
                        )
                        onAdd(sub)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canAdd)
                }
            }
        }
    }
}

// MARK: - Settings Sheet

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedCurrencyID") private var selectedCurrencyID = "USD"

    var body: some View {
        NavigationView {
            Form {
                Section("Currency") {
                    ForEach(allCurrencies) { currency in
                        Button {
                            selectedCurrencyID = currency.id
                        } label: {
                            HStack {
                                Text(currency.flag).font(.system(size: 22))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(currency.name).foregroundColor(.primary).font(.system(size: 16))
                                    Text(currency.id).foregroundColor(.secondary).font(.system(size: 13))
                                }
                                Spacer()
                                Text(currency.symbol)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 15, design: .monospaced))
                                if selectedCurrencyID == currency.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    Button("Privacy Policy") {
                        if let url = URL(string: "https://torpid-helmet-1c4.notion.site/Privacy-Policy-for-SubTracker-67a62974d3bd455496e015f54ff93276") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }
}
