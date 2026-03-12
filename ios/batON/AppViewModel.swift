import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var benefactors: [Benefactor] = []
    @Published var kindnessActs: [KindnessAct] = []
    @Published var reports: [Report] = []

    // MARK: - 統計
    var thisMonthActCount: Int {
        let now = Date()
        return kindnessActs.filter {
            Calendar.current.isDate($0.actDate, equalTo: now, toGranularity: .month)
        }.count
    }

    var reportedCount: Int { kindnessActs.filter { $0.isReported }.count }
    var pendingReportCount: Int { kindnessActs.filter { !$0.isReported }.count }

    var actsByMonth: [(String, [KindnessAct])] {
        let sorted = kindnessActs.sorted { $0.actDate > $1.actDate }
        let grouped = Dictionary(grouping: sorted) { $0.monthString }
        return grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value) }
    }

    var pendingReports: [Report] { reports.filter { !$0.isCompleted } }
    var completedReports: [Report] { reports.filter { $0.isCompleted } }

    // MARK: - CRUD
    func addBenefactor(name: String, relation: String, kindnessDescription: String) {
        let new = Benefactor(
            id: UUID().uuidString,
            name: name,
            relation: relation,
            kindnessDescription: kindnessDescription,
            kindnessActCount: 0
        )
        benefactors.append(new)
    }

    func addKindnessAct(
        benefactorId: String, title: String, description: String,
        category: KindnessCategory, actDate: Date, recipientName: String
    ) {
        let new = KindnessAct(
            id: UUID().uuidString,
            benefactorId: benefactorId,
            title: title,
            description: description,
            category: category,
            actDate: actDate,
            recipientName: recipientName,
            isReported: false
        )
        kindnessActs.append(new)
        if let i = benefactors.firstIndex(where: { $0.id == benefactorId }) {
            benefactors[i].kindnessActCount += 1
        }
    }

    func sendReport(for act: KindnessAct, benefactorName: String, message: String) {
        if let i = kindnessActs.firstIndex(where: { $0.id == act.id }) {
            kindnessActs[i].isReported = true
        }
        let report = Report(
            id: UUID().uuidString,
            kindnessActId: act.id,
            benefactorId: act.benefactorId,
            activityTitle: act.title,
            benefactorName: benefactorName,
            message: message,
            status: .sent,
            createdAt: Date()
        )
        reports.append(report)
    }

    func benefactor(for id: String) -> Benefactor? {
        benefactors.first { $0.id == id }
    }

    // MARK: - モックデータ
    init() { loadMockData() }

    private func loadMockData() {
        let cal = Calendar.current
        let now = Date()

        let b1 = Benefactor(id: "b1", name: "田中太郎", relation: "父", kindnessDescription: "受験勉強を毎晩支えてくれた", kindnessActCount: 3)
        let b2 = Benefactor(id: "b2", name: "山田花子", relation: "友人", kindnessDescription: "辛いときいつも相談に乗ってくれた", kindnessActCount: 1)
        let b3 = Benefactor(id: "b3", name: "佐藤先生", relation: "学校の先生", kindnessDescription: "進路について真剣に向き合ってくれた", kindnessActCount: 0)
        benefactors = [b1, b2, b3]

        let act1 = KindnessAct(id: "a1", benefactorId: "b2", title: "友人Aに数学を教えた", description: "数学が苦手な後輩に放課後2時間教えた", category: .study, actDate: cal.date(byAdding: .day, value: -4, to: now)!, recipientName: "田中", isReported: false)
        let act2 = KindnessAct(id: "a2", benefactorId: "b1", title: "父のPCを修理した", description: "マルウェアに感染したPCをクリーンアップして修復した", category: .labor, actDate: cal.date(byAdding: .day, value: -7, to: now)!, recipientName: "父", isReported: true)
        let act3 = KindnessAct(id: "a3", benefactorId: "b3", title: "新入社員研修のメンター", description: "新入社員のオンボーディングをサポートした", category: .skill, actDate: cal.date(byAdding: .day, value: -11, to: now)!, recipientName: "新入社員", isReported: true)
        let act4 = KindnessAct(id: "a4", benefactorId: "b1", title: "友人の引越しを手伝った", description: "重い荷物を運ぶのを手伝った", category: .labor, actDate: cal.date(byAdding: .day, value: -40, to: now)!, recipientName: "佐藤", isReported: true)
        kindnessActs = [act1, act2, act3, act4]

        let r1 = Report(id: "r1", kindnessActId: "a2", benefactorId: "b1", activityTitle: "父のPCを修理した", benefactorName: "田中太郎（父）", message: "お父さんのおかげで困っている人を助けられました。", status: .sent, createdAt: cal.date(byAdding: .day, value: -7, to: now)!)
        let r2 = Report(id: "r2", kindnessActId: "a3", benefactorId: "b3", activityTitle: "新入社員研修のメンター", benefactorName: "佐藤先生", message: "先生に進路を教えていただいたように、後輩の道を照らせました。", status: .sent, createdAt: cal.date(byAdding: .day, value: -11, to: now)!)
        reports = [r1, r2]
    }
}
