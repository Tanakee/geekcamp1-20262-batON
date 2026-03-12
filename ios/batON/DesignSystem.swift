import SwiftUI

// MARK: - カラー定義
extension Color {
    static let batPrimary = Color(hex: "#FF6B6B")
    static let batSecondary = Color(hex: "#4ECDC4")
    static let batAccent = Color(hex: "#FFE66D")
    static let batBackground = Color(hex: "#0F0F1A")
    static let batCard = Color(hex: "#1C1C2E")
    static let batCardLight = Color(hex: "#252540")
    static let batTextPrimary = Color.white
    static let batTextSecondary = Color(hex: "#9E9EB8")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - グラデーション定義
extension LinearGradient {
    static let batPrimaryGradient = LinearGradient(
        colors: [Color.batPrimary, Color.batPrimary.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let batCardGradient = LinearGradient(
        colors: [Color.batCard, Color.batCardLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let batChainGradient = LinearGradient(
        colors: [Color.batPrimary, Color.batSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - カードスタイル
struct BatCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.batCard)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
    }
}

extension View {
    func batCard() -> some View {
        modifier(BatCard())
    }
}

// MARK: - プライマリボタン
struct BatPrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(LinearGradient.batPrimaryGradient)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(color: Color.batPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - カテゴリバッジ
struct CategoryBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.batSecondary.opacity(0.2))
            .foregroundColor(Color.batSecondary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.batSecondary.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - テキストフィールド
struct BatTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.batTextSecondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(Color.batTextPrimary)
                .padding()
                .background(Color.batCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.batCardLight, lineWidth: 1)
                )
        }
    }
}

// MARK: - パスワードフィールド
struct BatSecureField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.batTextSecondary)
            SecureField("", text: $text)
                .foregroundColor(Color.batTextPrimary)
                .padding()
                .background(Color.batCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.batCardLight, lineWidth: 1)
                )
        }
    }
}

// MARK: - ステータスバッジ
struct StatusBadge: View {
    let status: String
    var isCompleted: Bool {
        status.contains("報告済み") || status.contains("送信") || status.contains("既読")
    }

    var body: some View {
        Text(status)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isCompleted ? Color.batSecondary.opacity(0.2) : Color.batAccent.opacity(0.2))
            .foregroundColor(isCompleted ? Color.batSecondary : Color.batAccent)
            .cornerRadius(8)
    }
}
