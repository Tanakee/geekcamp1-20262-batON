import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {

                    // ロゴ
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.batPrimaryGradient)
                                .frame(width: 96, height: 96)
                                .shadow(color: Color.batPrimary.opacity(0.4), radius: 20, x: 0, y: 8)
                            Text("🏹")
                                .font(.system(size: 44))
                        }
                        VStack(spacing: 6) {
                            Text("batON")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                            Text("恩を送り、つながりを紡ぐ")
                                .font(.system(size: 14))
                                .foregroundColor(Color.batTextSecondary)
                        }
                    }
                    .padding(.top, 64)

                    // フォーム
                    VStack(spacing: 16) {
                        BatTextField(
                            label: "メールアドレス",
                            text: $email,
                            placeholder: "example@email.com",
                            keyboardType: .emailAddress
                        )
                        BatSecureField(label: "パスワード", text: $password)

                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(Color.batPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)

                    // ボタン
                    VStack(spacing: 16) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(Color.batPrimary)
                                .frame(height: 52)
                        } else {
                            BatPrimaryButton(title: "ログイン", icon: "arrow.right") {
                                authViewModel.login(email: email, password: password)
                            }
                        }

                        Button {
                            authViewModel.errorMessage = nil
                            showSignUp = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("アカウントをお持ちでない方")
                                    .foregroundColor(Color.batTextSecondary)
                                Text("新規登録")
                                    .foregroundColor(Color.batSecondary)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
