import Foundation

struct Notification: Identifiable {
    let id: String
    let userId: String
    let type: NotificationType
    let title: String
    let message: String
    let relatedUserId: String?
    let relatedPostId: String?
    let isRead: Bool
    let createdAt: Date
    let readAt: Date?

    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: createdAt, to: now)

        if let day = components.day, day == 0 {
            formatter.dateFormat = "H:mm"
            return formatter.string(from: createdAt)
        } else if let day = components.day, day == 1 {
            return "昨日"
        } else if let day = components.day, day < 7 {
            return "\(day)日前"
        } else {
            formatter.dateFormat = "M月d日"
            return formatter.string(from: createdAt)
        }
    }
}

enum NotificationType: String, Codable {
    case match = "match"
    case message = "message"
    case postLike = "post_like"
    case postComment = "post_comment"
    case follow = "follow"
    case skillMatch = "skill_match"

    var icon: String {
        switch self {
        case .match:
            return "heart.fill"
        case .message:
            return "bubble.right.fill"
        case .postLike:
            return "hand.thumbsup.fill"
        case .postComment:
            return "bubble.left.fill"
        case .follow:
            return "person.badge.plus.fill"
        case .skillMatch:
            return "checkmark.circle.fill"
        }
    }

    var displayName: String {
        switch self {
        case .match:
            return "マッチング"
        case .message:
            return "メッセージ"
        case .postLike:
            return "いいね"
        case .postComment:
            return "コメント"
        case .follow:
            return "フォロー"
        case .skillMatch:
            return "スキルマッチ"
        }
    }
}

struct NotificationSettings: Identifiable {
    let id: String
    let userId: String
    let matchNotifications: Bool
    let messageNotifications: Bool
    let postLikeNotifications: Bool
    let postCommentNotifications: Bool
    let followNotifications: Bool
    let skillMatchNotifications: Bool
    let notificationStartHour: Int  // 0-23
    let notificationEndHour: Int    // 0-23
    let createdAt: Date
    let updatedAt: Date
}
