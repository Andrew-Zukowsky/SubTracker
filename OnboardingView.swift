import SwiftUI

struct Currency: Identifiable {
    let id:     String
    let name:   String
    let symbol: String
    let flag:   String
}

let allCurrencies: [Currency] = [
    Currency(id: "USD", name: "US Dollar",         symbol: "$",   flag: "🇺🇸"),
    Currency(id: "EUR", name: "Euro",               symbol: "€",   flag: "🇪🇺"),
    Currency(id: "GBP", name: "British Pound",      symbol: "£",   flag: "🇬🇧"),
    Currency(id: "CAD", name: "Canadian Dollar",    symbol: "$",   flag: "🇨🇦"),
    Currency(id: "AUD", name: "Australian Dollar",  symbol: "$",   flag: "🇦🇺"),
    Currency(id: "JPY", name: "Japanese Yen",       symbol: "¥",   flag: "🇯🇵"),
    Currency(id: "CNY", name: "Chinese Yuan",       symbol: "¥",   flag: "🇨🇳"),
    Currency(id: "INR", name: "Indian Rupee",       symbol: "₹",   flag: "🇮🇳"),
    Currency(id: "BRL", name: "Brazilian Real",     symbol: "R$",  flag: "🇧🇷"),
    Currency(id: "MXN", name: "Mexican Peso",       symbol: "$",   flag: "🇲🇽"),
    Currency(id: "KRW", name: "South Korean Won",   symbol: "₩",   flag: "🇰🇷"),
    Currency(id: "CHF", name: "Swiss Franc",        symbol: "Fr",  flag: "🇨🇭"),
    Currency(id: "SEK", name: "Swedish Krona",      symbol: "kr",  flag: "🇸🇪"),
    Currency(id: "NOK", name: "Norwegian Krone",    symbol: "kr",  flag: "🇳🇴"),
    Currency(id: "DKK", name: "Danish Krone",       symbol: "kr",  flag: "🇩🇰"),
    Currency(id: "SGD", name: "Singapore Dollar",   symbol: "$",   flag: "🇸🇬"),
    Currency(id: "HKD", name: "Hong Kong Dollar",   symbol: "$",   flag: "🇭🇰"),
    Currency(id: "NZD", name: "New Zealand Dollar", symbol: "$",   flag: "🇳🇿"),
    Currency(id: "ZAR", name: "South African Rand", symbol: "R",   flag: "🇿🇦"),
    Currency(id: "AED", name: "UAE Dirham",         symbol: "د.إ", flag: "🇦🇪"),
]

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedCurrencyID")     private var selectedCurrencyID     = "USD"
    @State private var selected = "USD"

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("💸")
                    .font(.system(size: 64))
                    .padding(.top, 60)
                Text("Subscriptions101")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                Text("What currency do you use?")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)

            List {
                ForEach(allCurrencies) { currency in
                    Button {
                        selected = currency.id
                    } label: {
                        HStack(spacing: 14) {
                            Text(currency.flag).font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.name).font(.system(size: 16)).foregroundColor(.primary)
                                Text(currency.id).font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(currency.symbol)
                                .font(.system(size: 17, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 36, alignment: .trailing)
                            if selected == currency.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.insetGrouped)

            Button {
                selectedCurrencyID = selected
                hasCompletedOnboarding = true
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
