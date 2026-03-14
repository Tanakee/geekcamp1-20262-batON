import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var bio = ""
    @State private var selectedSkills: [String] = []

    private let availableSkills = [
        "プログラミング", "ウェブデザイン", "データ分析",
        "英語教育", "日本語教育", "ビジネスコンサル", "マーケティング",
        "イラスト", "写真", "動画編集",
        "料理", "フィットネス", "ガーデニング",
        "音楽", "執筆"
    ]

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

                        // 自己紹介
                        VStack(alignment: .leading, spacing: 8) {
                            Text("自己紹介")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)
                            TextField("自分のことを紹介してください（任意）", text: $bio)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 13))
                                .frame(height: 80)
                        }

                        // スキル選択
                        VStack(alignment: .leading, spacing: 8) {
                            Text("スキル（最大5個まで選択）")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            VStack(spacing: 8) {
                                ForEach(availableSkills, id: \.self) { skill in
                                    Button {
                                        if selectedSkills.contains(skill) {
                                            selectedSkills.removeAll { $0 == skill }
                                        } else if selectedSkills.count < 5 {
                                            selectedSkills.append(skill)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedSkills.contains(skill) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(selectedSkills.contains(skill) ? Color.batPrimary : Color.batTextSecondary)
                                            Text(skill)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.batTextPrimary)
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }

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
                                    authViewModel.signUp(name: name, email: email, password: password, bio: bio, skills: selectedSkills)
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
