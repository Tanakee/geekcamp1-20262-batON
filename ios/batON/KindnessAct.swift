import Foundation

enum KindnessCategory: String, CaseIterable {
    case study = "学業支援"
    case labor = "労働支援"
    case skill = "スキル共有"
    case emotional = "精神的サポート"
    case finance = "金銭的支援"
    case other = "その他"

    var icon: String {
        switch self {
        case .study:    return "📚"
        case .labor:    return "🔧"
        case .skill:    return "💡"
        case .emotional: return "💙"
        case .finance:  return "💰"
        case .other:    return "✨"
        }
    }
}

struct KindnessAct: Identifiable {
    let id: String
    let benefactorId: String
    let title: String
    var description: String
    let category: KindnessCategory
    let actDate: Date
    var recipientName: String
    var isReported: Bool

    var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M月d日"
        return f.string(from: actDate)
    }

    var monthString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月"
        return f.string(from: actDate)
    }

    var statusText: String { isReported ? "✓ 報告済み" : "報告待ち" }
}
