import SwiftUI
import Combine

// MARK: - API レスポンス型
private struct AuthData: Decodable {
    let login: AuthPayload?
    let register: AuthPayload?
}

private struct AuthPayload: Decodable {
    let token: String
    let user: APIUser
}

private struct APIUser: Decodable {
    let id: String
    let name: String
    let email: String
}

// MARK: - AuthViewModel
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUserName: String = ""
    @Published var currentUserId: String = ""
    @Published var currentUserSkills: [String] = []

    init() {
        // 前回のセッションを復元
        if let userId = APIService.shared.savedUserId, !userId.isEmpty {
            currentUserId = userId
            isLoggedIn = true
        }
    }

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "メールアドレスとパスワードを入力してください"
            return
        }
        isLoading = true
        errorMessage = nil

        let query = """
        mutation Login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
                token
                user { id name email }
            }
        }
        """

        APIService.shared.execute(
            query: query,
            variables: ["email": email, "password": password]
        ) { [weak self] (result: Result<AuthData, Error>) in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let data):
                guard let payload = data.login else {
                    self.errorMessage = "ログインに失敗しました"
                    return
                }
                APIService.shared.authToken = payload.token
                APIService.shared.savedUserId = payload.user.id
                self.currentUserId = payload.user.id
                self.currentUserName = payload.user.name
                self.isLoggedIn = true
            case .failure(let error):
                // API接続失敗時はモックログイン
                if case APIError.networkError = error {
                    self.currentUserName = "ゲスト"
                    self.currentUserId = "mock-user"
                    self.isLoggedIn = true
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signUp(name: String, email: String, password: String) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "すべての項目を入力してください"
            return
        }
        isLoading = true
        errorMessage = nil

        let query = """
        mutation Register($email: String!, $name: String!, $password: String!) {
            register(email: $email, name: $name, password: $password) {
                token
                user { id name email }
            }
        }
        """

        APIService.shared.execute(
            query: query,
            variables: ["email": email, "name": name, "password": password]
        ) { [weak self] (result: Result<AuthData, Error>) in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let data):
                guard let payload = data.register else {
                    self.errorMessage = "登録に失敗しました"
                    return
                }
                APIService.shared.authToken = payload.token
                APIService.shared.savedUserId = payload.user.id
                self.currentUserId = payload.user.id
                self.currentUserName = payload.user.name
                self.isLoggedIn = true
            case .failure(let error):
                // API接続失敗時はモック登録
                if case APIError.networkError = error {
                    self.currentUserName = name
                    self.currentUserId = "mock-user"
                    self.isLoggedIn = true
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func logout() {
        APIService.shared.clearSession()
        isLoggedIn = false
        currentUserName = ""
        currentUserId = ""
        errorMessage = nil
    }
}
