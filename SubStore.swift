import SwiftUI
import Combine

// MARK: - Enums

enum BillingCycle: String, CaseIterable, Codable {
    case weekly  = "Weekly"
    case monthly = "Monthly"
    case yearly  = "Yearly"
}

enum SubCategory: String, CaseIterable, Codable {
    case streaming = "Streaming"
    case music     = "Music"
    case software  = "Software"
    case gaming    = "Gaming"
    case news      = "News"
    case fitness   = "Fitness"
    case food      = "Food"
    case other     = "Other"

    var color: Color {
        switch self {
        case .streaming: return Color(red: 1.0,  green: 0.23, blue: 0.19)
        case .music:     return Color(red: 1.0,  green: 0.18, blue: 0.33)
        case .software:  return Color(red: 0.0,  green: 0.48, blue: 1.0)
        case .gaming:    return Color(red: 0.35, green: 0.34, blue: 0.84)
        case .news:      return Color(red: 1.0,  green: 0.58, blue: 0.0)
        case .fitness:   return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .food:      return Color(red: 1.0,  green: 0.42, blue: 0.0)
        case .other:     return Color(red: 0.56, green: 0.56, blue: 0.58)
        }
    }

    var emoji: String {
        switch self {
        case .streaming: return "📺"
        case .music:     return "🎵"
        case .software:  return "💻"
        case .gaming:    return "🎮"
        case .news:      return "📰"
        case .fitness:   return "💪"
        case .food:      return "🍔"
        case .other:     return "📦"
        }
    }
}

// MARK: - Model

struct Subscription: Identifiable, Codable {
    var id          = UUID()
    var name:       String
    var category:   SubCategory
    var amount:     Double
    var cycle:      BillingCycle
    var renewalDate: Date?

    var monthlyAmount: Double {
        switch cycle {
        case .weekly:  return amount * 4.33
        case .monthly: return amount
        case .yearly:  return amount / 12.0
        }
    }

    // Days until next renewal
    var daysUntilRenewal: Int? {
        guard let date = renewalDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let renewal = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: today, to: renewal)
        return components.day
    }

    // Renewal status label and color
    var renewalLabel: String? {
        guard let days = daysUntilRenewal else { return nil }
        if days < 0  { return "Renewed" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "in \(days) days"
    }

    var renewalColor: Color {
        guard let days = daysUntilRenewal else { return .secondary }
        if days <= 0  { return Color(red: 0.56, green: 0.56, blue: 0.58) }
        if days <= 3  { return Color(red: 1.0,  green: 0.23, blue: 0.19) }
        if days <= 7  { return Color(red: 1.0,  green: 0.58, blue: 0.0) }
        return Color(red: 0.20, green: 0.78, blue: 0.35)
    }
}

// MARK: - Currency formatter

func currencyString(_ value: Double) -> String {
    let currencyID = UserDefaults.standard.string(forKey: "selectedCurrencyID") ?? "USD"
    let symbol = allCurrencies.first(where: { $0.id == currencyID })?.symbol ?? "$"
    return "\(symbol)\(String(format: "%.2f", value))"
}

extension Double {
    var currency: String { currencyString(self) }
}

// MARK: - Store

final class SubStore: ObservableObject {
    var subscriptions: [Subscription] = [] {
        willSet { objectWillChange.send() }
        didSet  { save() }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    init() { load() }

    var monthlyTotal: Double { subscriptions.reduce(0) { $0 + $1.monthlyAmount } }
    var yearlyTotal:  Double { monthlyTotal * 12.0 }

    var categoryBreakdown: [(SubCategory, Double)] {
        var map: [SubCategory: Double] = [:]
        subscriptions.forEach { map[$0.category, default: 0] += $0.monthlyAmount }
        return map.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }

    // Subscriptions renewing within 7 days
    var renewingSoon: [Subscription] {
        subscriptions.filter {
            if let days = $0.daysUntilRenewal { return days >= 0 && days <= 7 }
            return false
        }.sorted { ($0.daysUntilRenewal ?? 99) < ($1.daysUntilRenewal ?? 99) }
    }

    func add(_ sub: Subscription)     { subscriptions.append(sub) }
    func delete(at offsets: IndexSet) { subscriptions.remove(atOffsets: offsets) }
    func move(from source: IndexSet, to destination: Int) {
        subscriptions.move(fromOffsets: source, toOffset: destination)
    }

    private let saveKey = "subscriptions101v2"

    private func save() {
        if let data = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode([Subscription].self, from: data) {
            subscriptions = saved
        } else {
            let cal = Calendar.current
            subscriptions = [
                Subscription(name: "Netflix",         category: .streaming, amount: 15.99,  cycle: .monthly, renewalDate: cal.date(byAdding: .day, value: 3,  to: Date())),
                Subscription(name: "Spotify",         category: .music,     amount: 9.99,   cycle: .monthly, renewalDate: cal.date(byAdding: .day, value: 12, to: Date())),
                Subscription(name: "iCloud+",         category: .software,  amount: 2.99,   cycle: .monthly, renewalDate: cal.date(byAdding: .day, value: 1,  to: Date())),
                Subscription(name: "YouTube Premium", category: .streaming, amount: 13.99,  cycle: .monthly, renewalDate: cal.date(byAdding: .day, value: 20, to: Date())),
                Subscription(name: "Adobe CC",        category: .software,  amount: 599.88, cycle: .yearly,  renewalDate: cal.date(byAdding: .day, value: 45, to: Date())),
            ]
        }
    }
}
