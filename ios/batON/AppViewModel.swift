import SwiftUI
import Combine

// MARK: - API レスポンス型
private struct BenefactorsData: Decodable {
    let benefactors: [APIBenefactor]
}
private struct KindnessActsData: Decodable {
    let kindnessActs: [APIKindnessAct]
}
private struct ReportsData: Decodable {
    let reports: [APIReport]
}
private struct PostsData: Decodable {
    let posts: [APIPost]
}
private struct APIPost: Decodable {
    let id: String
    let userId: String
    let type: String
    let title: String
    let description: String
    let category: String?
    let tags: [String]?
    let location: String?
    let status: String
    let likesCount: Int
    let commentsCount: Int
    let createdAt: String
}

private struct APIBenefactor: Decodable {
    let id: String
    let name: String
    let relation: String?
    let kindnessDescription: String?
    let kindnessActCount: Int
}
private struct APIKindnessAct: Decodable {
    let id: String
    let benefactorId: String
    let title: String
    let description: String?
    let category: String
    let actDate: String
    let recipientName: String
    let isReported: Bool
}
private struct APIReport: Decodable {
    let id: String
    let kindnessActId: String
    let benefactorId: String
    let message: String
    let status: String
    let createdAt: String
}

// MARK: - AppViewModel
class AppViewModel: ObservableObject {
    @Published var benefactors: [Benefactor] = []
    @Published var kindnessActs: [KindnessAct] = []
    @Published var reports: [Report] = []
    @Published var posts: [Post] = []
    @Published var isLoadingData: Bool = false
    @Published var apiError: String? = nil

    private var userId: String = ""
    private var pendingFetches: Int = 0 {
        didSet { isLoadingData = pendingFetches > 0 }
    }

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

    init() { loadMockData() }

    // MARK: - APIからデータ取得
    func loadFromAPI(userId: String) {
        guard !userId.isEmpty, userId != "mock-user" else { return }
        self.userId = userId
        apiError = nil
        // APIユーザーはモックデータを消去して実データに入れ替え
        benefactors = []
        kindnessActs = []
        reports = []
        pendingFetches = 3
        fetchBenefactors(userId: userId)
        fetchKindnessActs(userId: userId)
        fetchReports(userId: userId)
    }

    private func fetchBenefactors(userId: String) {
        let query = """
        query Benefactors($userId: ID!) {
            benefactors(userId: $userId) {
                id name relation kindnessDescription kindnessActCount
            }
        }
        """
        APIService.shared.execute(query: query, variables: ["userId": userId]) { [weak self] (result: Result<BenefactorsData, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.benefactors = data.benefactors.map {
                        Benefactor(id: $0.id, name: $0.name, relation: $0.relation ?? "", kindnessDescription: $0.kindnessDescription ?? "", kindnessActCount: $0.kindnessActCount)
                    }
                case .failure(let error):
                    if case APIError.networkError = error { } else {
                        self?.apiError = "データの取得に失敗しました"
                    }
                }
                self?.pendingFetches -= 1
            }
        }
    }

    private func fetchKindnessActs(userId: String) {
        let query = """
        query KindnessActs($userId: ID!) {
            kindnessActs(userId: $userId) {
                id benefactorId title description category actDate recipientName isReported
            }
        }
        """
        APIService.shared.execute(query: query, variables: ["userId": userId]) { [weak self] (result: Result<KindnessActsData, Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self?.kindnessActs = data.kindnessActs.compactMap { act in
                        let date = formatter.date(from: String(act.actDate.prefix(10))) ?? Date()
                        let category = KindnessCategory(rawValue: act.category) ?? .other
                        return KindnessAct(id: act.id, benefactorId: act.benefactorId, title: act.title, description: act.description ?? "", category: category, actDate: date, recipientName: act.recipientName, isReported: act.isReported)
                    }
                }
                self?.pendingFetches -= 1
            }
        }
    }

    private func fetchReports(userId: String) {
        let query = """
        query Reports($userId: ID!) {
            reports(userId: $userId) {
                id kindnessActId benefactorId message status createdAt
            }
        }
        """
        APIService.shared.execute(query: query, variables: ["userId": userId]) { [weak self] (result: Result<ReportsData, Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    let formatter = ISO8601DateFormatter()
                    self?.reports = data.reports.compactMap { r in
                        let date = formatter.date(from: r.createdAt) ?? Date()
                        let status: ReportStatus = r.status == "SENT" ? .sent : .draft
                        let act = self?.kindnessActs.first { $0.id == r.kindnessActId }
                        let benefactor = self?.benefactors.first { $0.id == r.benefactorId }
                        return Report(id: r.id, kindnessActId: r.kindnessActId, benefactorId: r.benefactorId, activityTitle: act?.title ?? "", benefactorName: benefactor?.name ?? "", message: r.message, status: status, createdAt: date)
                    }
                }
                self?.pendingFetches -= 1
            }
        }
    }

    // MARK: - SNS フィード取得
    func loadPosts() {
        let query = """
        query Posts($limit: Int, $offset: Int) {
            posts(limit: $limit, offset: $offset) {
                id userId type title description category tags location status likesCount commentsCount createdAt
            }
        }
        """
        isLoadingData = true
        apiError = nil
        APIService.shared.execute(query: query, variables: ["limit": 20, "offset": 0]) { [weak self] (result: Result<PostsData, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let formatter = ISO8601DateFormatter()
                    self?.posts = data.posts.compactMap { apiPost in
                        let type = PostType(rawValue: apiPost.type) ?? .help_request
                        let status = PostStatus(rawValue: apiPost.status) ?? .open
                        let date = formatter.date(from: apiPost.createdAt) ?? Date()
                        return Post(
                            id: apiPost.id,
                            userId: apiPost.userId,
                            userName: nil, // TODO: ユーザー情報が必要な場合は別フェッチ
                            type: type,
                            title: apiPost.title,
                            description: apiPost.description,
                            category: apiPost.category,
                            tags: apiPost.tags ?? [],
                            location: apiPost.location,
                            status: status,
                            likesCount: apiPost.likesCount,
                            commentsCount: apiPost.commentsCount,
                            createdAt: date
                        )
                    }
                case .failure(let error):
                    if case APIError.networkError = error { } else {
                        self?.apiError = "フィードの読み込みに失敗しました"
                    }
                }
                self?.isLoadingData = false
            }
        }
    }

    // MARK: - CRUD（API + ローカル反映）
    func addBenefactor(name: String, relation: String, kindnessDescription: String) {
        let tempId = UUID().uuidString
        let new = Benefactor(id: tempId, name: name, relation: relation, kindnessDescription: kindnessDescription, kindnessActCount: 0)
        benefactors.append(new)

        guard !userId.isEmpty, userId != "mock-user" else { return }
        let mutation = """
        mutation CreateBenefactor($userId: ID!, $name: String!, $relation: String, $kindnessDescription: String) {
            createBenefactor(userId: $userId, name: $name, relation: $relation, kindnessDescription: $kindnessDescription) {
                id name relation kindnessDescription kindnessActCount
            }
        }
        """
        struct CreateData: Decodable { let createBenefactor: APIBenefactor }
        APIService.shared.execute(query: mutation, variables: ["userId": userId, "name": name, "relation": relation, "kindnessDescription": kindnessDescription]) { [weak self] (result: Result<CreateData, Error>) in
            if case .success(let data) = result, let i = self?.benefactors.firstIndex(where: { $0.id == tempId }) {
                self?.benefactors[i] = Benefactor(id: data.createBenefactor.id, name: data.createBenefactor.name, relation: data.createBenefactor.relation ?? "", kindnessDescription: data.createBenefactor.kindnessDescription ?? "", kindnessActCount: 0)
            }
        }
    }

    func addKindnessAct(benefactorId: String, title: String, description: String, category: KindnessCategory, actDate: Date, recipientName: String) {
        let tempId = UUID().uuidString
        let new = KindnessAct(id: tempId, benefactorId: benefactorId, title: title, description: description, category: category, actDate: actDate, recipientName: recipientName, isReported: false)
        kindnessActs.insert(new, at: 0)
        if let i = benefactors.firstIndex(where: { $0.id == benefactorId }) {
            benefactors[i].kindnessActCount += 1
        }

        guard !userId.isEmpty, userId != "mock-user" else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let actDateStr = formatter.string(from: actDate)
        let mutation = """
        mutation CreateKindnessAct($userId: ID!, $benefactorId: ID!, $title: String!, $description: String, $category: String!, $actDate: String!, $recipientName: String!) {
            createKindnessAct(userId: $userId, benefactorId: $benefactorId, title: $title, description: $description, category: $category, actDate: $actDate, recipientName: $recipientName) {
                id benefactorId title description category actDate recipientName isReported
            }
        }
        """
        struct CreateActData: Decodable { let createKindnessAct: APIKindnessAct }
        let vars: [String: Any] = ["userId": userId, "benefactorId": benefactorId, "title": title, "description": description, "category": category.rawValue, "actDate": actDateStr, "recipientName": recipientName]
        APIService.shared.execute(query: mutation, variables: vars) { [weak self] (result: Result<CreateActData, Error>) in
            if case .success(let data) = result,
               let i = self?.kindnessActs.firstIndex(where: { $0.id == tempId }) {
                let act = data.createKindnessAct
                let date = formatter.date(from: String(act.actDate.prefix(10))) ?? actDate
                self?.kindnessActs[i] = KindnessAct(id: act.id, benefactorId: act.benefactorId, title: act.title, description: act.description ?? "", category: KindnessCategory(rawValue: act.category) ?? .other, actDate: date, recipientName: act.recipientName, isReported: act.isReported)
            }
        }
    }

    func sendReport(for act: KindnessAct, benefactorName: String, message: String) {
        // Optimistic update
        if let i = kindnessActs.firstIndex(where: { $0.id == act.id }) {
            kindnessActs[i].isReported = true
        }
        let tempId = UUID().uuidString
        let report = Report(id: tempId, kindnessActId: act.id, benefactorId: act.benefactorId, activityTitle: act.title, benefactorName: benefactorName, message: message, status: .sent, createdAt: Date())
        reports.insert(report, at: 0)

        guard !userId.isEmpty, userId != "mock-user" else { return }
        let createMutation = """
        mutation CreateReport($kindnessActId: ID!, $benefactorId: ID!, $userId: ID!, $message: String!) {
            createReport(kindnessActId: $kindnessActId, benefactorId: $benefactorId, userId: $userId, message: $message) {
                id
            }
        }
        """
        struct CreateReportData: Decodable { let createReport: APIReportId }
        struct APIReportId: Decodable { let id: String }
        let vars: [String: Any] = ["kindnessActId": act.id, "benefactorId": act.benefactorId, "userId": userId, "message": message]
        APIService.shared.execute(query: createMutation, variables: vars) { [weak self] (result: Result<CreateReportData, Error>) in
            guard case .success(let data) = result else { return }
            let reportId = data.createReport.id
            // tempId を実IDに差し替え
            if let i = self?.reports.firstIndex(where: { $0.id == tempId }) {
                self?.reports[i] = Report(id: reportId, kindnessActId: act.id, benefactorId: act.benefactorId, activityTitle: act.title, benefactorName: benefactorName, message: message, status: .sent, createdAt: Date())
            }
            let sendMutation = """
            mutation SendReport($id: ID!) {
                sendReport(id: $id) { id status sentAt }
            }
            """
            struct SendReportData: Decodable { let sendReport: APIReportId }
            APIService.shared.execute(query: sendMutation, variables: ["id": reportId]) { (_: Result<SendReportData, Error>) in }
        }
    }

    func benefactor(for id: String) -> Benefactor? {
        benefactors.first { $0.id == id }
    }

    // MARK: - SNS ポスト作成
    func createPost(type: String, title: String, description: String, category: String, tags: [String], location: String?) {
        guard !userId.isEmpty, userId != "mock-user" else { return }

        let mutation = """
        mutation CreatePost($userId: ID!, $type: String!, $title: String!, $description: String!, $category: String, $tags: [String!], $location: String) {
            createPost(userId: $userId, type: $type, title: $title, description: $description, category: $category, tags: $tags, location: $location) {
                id userId type title description category tags location status likesCount commentsCount createdAt
            }
        }
        """

        struct CreatePostData: Decodable {
            let createPost: APIPost
        }

        let vars: [String: Any] = [
            "userId": userId,
            "type": type,
            "title": title,
            "description": description,
            "category": category,
            "tags": tags,
            "location": location ?? NSNull()
        ]

        APIService.shared.execute(query: mutation, variables: vars) { [weak self] (result: Result<CreatePostData, Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    let formatter = ISO8601DateFormatter()
                    let apiPost = data.createPost
                    let postType = PostType(rawValue: apiPost.type) ?? .help_request
                    let postStatus = PostStatus(rawValue: apiPost.status) ?? .open
                    let date = formatter.date(from: apiPost.createdAt) ?? Date()
                    let post = Post(
                        id: apiPost.id,
                        userId: apiPost.userId,
                        userName: nil,
                        type: postType,
                        title: apiPost.title,
                        description: apiPost.description,
                        category: apiPost.category,
                        tags: apiPost.tags ?? [],
                        location: apiPost.location,
                        status: postStatus,
                        likesCount: apiPost.likesCount,
                        commentsCount: apiPost.commentsCount,
                        createdAt: date
                    )
                    // 投稿をリスト先頭に追加（ローカル更新）
                    if self?.posts != nil {
                        self?.posts.insert(post, at: 0)
                    }
                } else {
                    self?.apiError = "ポストの作成に失敗しました"
                }
            }
        }
    }

    // MARK: - モックデータ（API未接続時のフォールバック）
    private func loadMockData() {
        let cal = Calendar.current
        let now = Date()
        let b1 = Benefactor(id: "b1", name: "田中太郎", relation: "父", kindnessDescription: "受験勉強を毎晩支えてくれた", kindnessActCount: 3)
        let b2 = Benefactor(id: "b2", name: "山田花子", relation: "友人", kindnessDescription: "辛いときいつも相談に乗ってくれた", kindnessActCount: 1)
        let b3 = Benefactor(id: "b3", name: "佐藤先生", relation: "学校の先生", kindnessDescription: "進路について真剣に向き合ってくれた", kindnessActCount: 0)
        benefactors = [b1, b2, b3]
        let act1 = KindnessAct(id: "a1", benefactorId: "b2", title: "友人Aに数学を教えた", description: "数学が苦手な後輩に放課後2時間教えた", category: .study, actDate: cal.date(byAdding: .day, value: -4, to: now)!, recipientName: "田中", isReported: false)
        let act2 = KindnessAct(id: "a2", benefactorId: "b1", title: "父のPCを修理した", description: "マルウェアに感染したPCをクリーンアップした", category: .labor, actDate: cal.date(byAdding: .day, value: -7, to: now)!, recipientName: "父", isReported: true)
        let act3 = KindnessAct(id: "a3", benefactorId: "b3", title: "新入社員研修のメンター", description: "新入社員のオンボーディングをサポートした", category: .skill, actDate: cal.date(byAdding: .day, value: -11, to: now)!, recipientName: "新入社員", isReported: true)
        kindnessActs = [act1, act2, act3]
        let r1 = Report(id: "r1", kindnessActId: "a2", benefactorId: "b1", activityTitle: "父のPCを修理した", benefactorName: "田中太郎（父）", message: "お父さんのおかげで困っている人を助けられました。", status: .sent, createdAt: cal.date(byAdding: .day, value: -7, to: now)!)
        reports = [r1]
    }
}
