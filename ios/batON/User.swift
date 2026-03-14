import Foundation

struct User: Identifiable {
    let id: String
    let email: String
    let name: String
    let avatarUrl: String?
    let bio: String?
    let skills: [String]
    let rating: Double
    let totalRatings: Int
    let followersCount: Int
    let followingCount: Int
    let postsCount: Int
    let completedActsCount: Int
    let isActive: Bool
    let createdAt: Date

    var ratingString: String {
        String(format: "%.1f", rating)
    }

    var joinedDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月d日"
        return f.string(from: createdAt)
    }
}
