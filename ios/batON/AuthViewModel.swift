import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUserName: String = ""

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "メールアドレスとパスワードを入力してください"
            return
        }
        isLoading = true
        errorMessage = nil
        // TODO: 実際のAPI呼び出しに置き換える
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.currentUserName = "田中 渓都"
            self.isLoggedIn = true
        }
    }

    func signUp(name: String, email: String, password: String) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "すべての項目を入力してください"
            return
        }
        isLoading = true
        errorMessage = nil
        // TODO: 実際のAPI呼び出しに置き換える
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.currentUserName = name
            self.isLoggedIn = true
        }
    }

    func logout() {
        isLoggedIn = false
        currentUserName = ""
        errorMessage = nil
    }
}
