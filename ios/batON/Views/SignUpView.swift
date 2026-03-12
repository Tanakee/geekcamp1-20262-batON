import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {

                    // ヘッダー
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.batTextSecondary)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 36, height: 36)
                                .background(Color.batCard)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // タイトル
                    VStack(spacing: 8) {
                        Text("アカウント作成")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                        Text("恩送りの旅を始めましょう")
                            .font(.system(size: 14))
                            .foregroundColor(Color.batTextSecondary)
                    }

                    // フォーム
                    VStack(spacing: 16) {
                        BatTextField(label: "名前", text: $name, placeholder: "例：田中 渓都")
                        BatTextField(
                            label: "メールアドレス",
                            text: $email,
                            placeholder: "example@email.com",
                            keyboardType: .emailAddress
                        )
                        BatSecureField(label: "パスワード", text: $password)
                        BatSecureField(label: "パスワード（確認）", text: $confirmPassword)

                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(Color.batPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)

                    // ボタン
                    VStack(spacing: 12) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(Color.batPrimary)
                                .frame(height: 52)
                        } else {
                            BatPrimaryButton(title: "登録する", icon: "sparkles") {
                                if password != confirmPassword {
                                    authViewModel.errorMessage = "パスワードが一致しません"
                                } else {
                                    authViewModel.signUp(name: name, email: email, password: password)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
