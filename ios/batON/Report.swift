import Foundation

enum ReportStatus: String {
    case draft = "DRAFT"
    case sent = "SENT"
}

struct Report: Identifiable {
    let id: String
    let kindnessActId: String
    let benefactorId: String
    let activityTitle: String
    let benefactorName: String
    var message: String
    var status: ReportStatus
    let createdAt: Date

    var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M月d日"
        return f.string(from: createdAt)
    }

    var isCompleted: Bool { status == .sent }
    var statusText: String { isCompleted ? "✓ 送信済み" : "未報告" }
}
