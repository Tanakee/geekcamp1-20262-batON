import SwiftUI

struct Benefactor: Identifiable {
    let id: String
    let name: String
    let relation: String
    let kindnessDescription: String
    var kindnessActCount: Int

    var initial: String { String(name.prefix(1)) }

    var avatarColor: Color {
        let colors: [Color] = [.batAccent, .batPrimary, .batSecondary]
        return colors[abs(name.hashValue) % colors.count]
    }
}
