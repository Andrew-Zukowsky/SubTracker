import SwiftUI

struct HeaderView: View {
    let monthlyTotal: Double
    let yearlyTotal:  Double
    let breakdown:    [(SubCategory, Double)]
    let subCount:     Int
    let renewingSoon: [Subscription]

    var body: some View {
        VStack(spacing: 12) {

            // Hero gradient card
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Total")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                Text(monthlyTotal.currency)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("\(yearlyTotal.currency) per year")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.65))
                    .padding(.bottom, 14)

                if !breakdown.isEmpty && monthlyTotal > 0 {
                    GeometryReader { geo in
                        HStack(spacing: 3) {
                            ForEach(Array(breakdown.enumerated()), id: \.offset) { _, pair in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.55))
                                    .frame(width: geo.size.width * CGFloat(pair.1 / monthlyTotal))
                            }
                        }
                    }
                    .frame(height: 4)
                    .padding(.bottom, 10)

                    HStack(spacing: 12) {
                        ForEach(Array(breakdown.prefix(4).enumerated()), id: \.offset) { _, pair in
                            HStack(spacing: 4) {
                                Circle().fill(Color.white.opacity(0.7)).frame(width: 6, height: 6)
                                Text("\(pair.0.rawValue) \(pair.1.currency)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0,  green: 0.48, blue: 1.0),
                        Color(red: 0.35, green: 0.34, blue: 0.84)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.3), radius: 16, x: 0, y: 8)

            // Renewing soon card
            if !renewingSoon.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                            .font(.system(size: 13))
                        Text("Renewing Soon")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    ForEach(renewingSoon) { sub in
                        HStack {
                            Text(sub.category.emoji).font(.system(size: 16))
                            Text(sub.name).font(.system(size: 14)).foregroundColor(.primary)
                            Spacer()
                            if let label = sub.renewalLabel {
                                Text(label)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(sub.renewalColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(sub.renewalColor.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            Text(sub.amount.currency)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(14)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
            }

            // Reality check
            if subCount > 0 {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.08))
                            .frame(width: 42, height: 42)
                        Text("💸").font(.system(size: 22))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        (Text("You spend ")
                         + Text(yearlyTotal.currency).foregroundColor(.red).fontWeight(.semibold)
                         + Text(" a year"))
                            .font(.system(size: 15))
                        Text("\(subCount) active subscription\(subCount != 1 ? "s" : "")")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}
