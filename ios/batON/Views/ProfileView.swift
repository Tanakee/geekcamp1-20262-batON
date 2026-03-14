import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    @State private var showLogoutAlert = false
    @State private var showEditProfile = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ナビゲーションバー
                HStack {
                    Text("プロフィール")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.batTextSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.batCard)

                ScrollView {
                    VStack(spacing: 20) {
                        // プロフィールヘッダー
                        profileHeader

                        // 統計情報
                        profileStats

                        // スキル情報
                        if !authViewModel.currentUserSkills.isEmpty {
                            skillsSection
                        }

                        // タブセクション
                        tabSection

                        Spacer().frame(height: 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(authViewModel)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient.batPrimaryGradient)
                    .frame(width: 80, height: 80)

                Text(String(authViewModel.currentUserName.prefix(1)))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text(authViewModel.currentUserName.isEmpty ? "ユーザー" : authViewModel.currentUserName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.batTextPrimary)

                // 評価表示
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("4.8")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.batTextPrimary)
                    Text("(12件)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }
            }

            // ボタン
            HStack(spacing: 12) {
                Button {
                    showEditProfile = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("編集")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.batPrimary)
                    .background(Color.batPrimary.opacity(0.1))
                    .cornerRadius(8)
                }

                Button {} label: {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("メッセージ")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .background(Color.batPrimary)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.batCard)
    }

    private var profileStats: some View {
        HStack(spacing: 0) {
            StatItem(icon: "sparkles", value: "5", label: "投稿")
            Divider().frame(height: 40).background(Color.batCardLight)
            StatItem(icon: "checkmark.circle", value: "3", label: "完了")
            Divider().frame(height: 40).background(Color.batCardLight)
            StatItem(icon: "person.2", value: "24", label: "フォロワー")
            Divider().frame(height: 40).background(Color.batCardLight)
            StatItem(icon: "person.2.fill", value: "18", label: "フォロー中")
        }
        .padding(.vertical, 16)
        .background(Color.batCard)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スキル")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.batTextPrimary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(authViewModel.currentUserSkills, id: \.self) { skill in
                        Text(skill)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.batPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.batPrimary.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(Color.batCard)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    private var tabSection: some View {
        VStack(spacing: 12) {
            Picker("", selection: $selectedTab) {
                Text("投稿").tag(0)
                Text("完了").tag(1)
                Text("フォロワー").tag(2)
                Text("フォロー中").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            switch selectedTab {
            case 0:
                // 投稿一覧（プレースホルダー）
                placeholderContent(icon: "sparkles", title: "投稿がまだありません")
            case 1:
                // 完了した活動
                placeholderContent(icon: "checkmark.circle", title: "完了した活動がまだありません")
            case 2:
                // フォロワー一覧
                placeholderContent(icon: "person.2", title: "フォロワーがまだいません")
            case 3:
                // フォロー中
                placeholderContent(icon: "person.2.fill", title: "誰もフォローしていません")
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 16)
    }

    private func placeholderContent(icon: String, title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color.batTextSecondary)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color.batTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 統計アイテム
struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Color.batPrimary)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.batTextPrimary)
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.batTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - プロフィール編集ビュー
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var skills: [String] = []
    @State private var currentSkill: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.batBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 名前編集
                        VStack(alignment: .leading, spacing: 8) {
                            Text("名前")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)
                            TextField("名前を入力", text: $name)
                                .padding(12)
                                .background(Color.batCard)
                                .cornerRadius(8)
                        }

                        // 自己紹介編集
                        VStack(alignment: .leading, spacing: 8) {
                            Text("自己紹介")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.batCard)
                                .cornerRadius(8)
                                .font(.system(size: 14))
                        }

                        // スキル追加
                        VStack(alignment: .leading, spacing: 8) {
                            Text("スキル")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            HStack {
                                TextField("スキルを追加", text: $currentSkill)
                                    .padding(12)
                                    .background(Color.batCard)
                                    .cornerRadius(8)

                                Button {
                                    if !currentSkill.isEmpty {
                                        skills.append(currentSkill)
                                        currentSkill = ""
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.batPrimary)
                                }
                            }

                            if !skills.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(Array(skills.enumerated()), id: \.offset) { index, skill in
                                        HStack(spacing: 4) {
                                            Text(skill)
                                                .font(.system(size: 12))
                                            Button {
                                                skills.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10))
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.batPrimary.opacity(0.15))
                                        .foregroundColor(Color.batPrimary)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Text("保存")
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .background(Color.batPrimary)
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthViewModel())
}
