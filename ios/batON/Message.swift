import Foundation

struct Conversation: Identifiable {
    let id: String
    let user1Id: String
    let user2Id: String
    let user1Name: String
    let user2Name: String
    let lastMessageText: String?
    let lastMessageAt: Date
    let unreadCount: Int

    var otherUserName: String {
        user1Name
    }

    var lastMessageTimeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(lastMessageAt) {
            formatter.dateFormat = "H:mm"
            return formatter.string(from: lastMessageAt)
        } else if calendar.isDateInYesterday(lastMessageAt) {
            return "昨日"
        } else {
            formatter.dateFormat = "M月d日"
            return formatter.string(from: lastMessageAt)
        }
    }
}

struct Message: Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let content: String
    let readAt: Date?
    let createdAt: Date

    var isRead: Bool {
        readAt != nil
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        return formatter.string(from: createdAt)
    }
}
