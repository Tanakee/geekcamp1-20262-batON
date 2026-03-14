import Foundation

enum PostType: String, CaseIterable {
    case help_offer = "恩を教えます"
    case help_request = "恩を受けたいです"

    var icon: String {
        switch self {
        case .help_offer: return "🤲"
        case .help_request: return "🙏"
        }
    }
}

enum PostStatus: String {
    case open = "募集中"
    case matched = "マッチ中"
    case completed = "完了"
    case closed = "終了"
}

struct Post: Identifiable {
    let id: String
    let userId: String
    let userName: String? // API呼び出しでは別フェッチ
    let type: PostType
    let title: String
    let description: String
    let category: String?
    let tags: [String]
    let location: String?
    let status: PostStatus
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Date

    var createdAtString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let calendar = Calendar.current
        let daysAgo = calendar.dateComponents([.day], from: createdAt, to: now).day ?? 0

        if daysAgo == 0 {
            f.dateFormat = "H:mm"
            return f.string(from: createdAt) + " に投稿"
        } else if daysAgo == 1 {
            return "昨日"
        } else if daysAgo < 7 {
            return "\(daysAgo)日前"
        } else {
            f.dateFormat = "M月d日"
            return f.string(from: createdAt)
        }
    }
}
