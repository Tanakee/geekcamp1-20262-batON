import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutAlert = false

    // バッジ解除条件
    private var badges: [(emoji: String, title: String, isUnlocked: Bool)] {
        let count = appViewModel.kindnessActs.count
        let reportedCount = appViewModel.reportedCount
        let usedCategories = Set(appViewModel.kindnessActs.map { $0.category })
        return [
            ("🌱", "初恩送り",    count >= 1),
            ("⭐", "5回達成",    count >= 5),
            ("🔥", "10回達成",   count >= 10),
            ("🌟", "全カテゴリ", usedCategories.count >= KindnessCategory.allCases.count),
            ("📬", "初報告",     reportedCount >= 1),
            ("💎", "30日連続",   false), // TODO: 連続記録機能
        ]
    }

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // プロフィールヘッダー
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.batPrimaryGradient)
                                .frame(width: 88, height: 88)
                                .shadow(color: Color.batPrimary.opacity(0.4), radius: 16, x: 0, y: 6)
                            Text(String(authViewModel.currentUserName.prefix(1)))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.batPrimary.opacity(0.3), lineWidth: 4)
                                .scaleEffect(1.15)
                        )

                        VStack(spacing: 4) {
                            Text(authViewModel.currentUserName.isEmpty ? "ユーザー" : authViewModel.currentUserName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                            Text("恩送りをつなぐ人")
                                .font(.system(size: 13))
                                .foregroundColor(Color.batTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)

                    // 統計
                    HStack(spacing: 0) {
                        ProfileStatItem(value: "\(appViewModel.kindnessActs.count)", label: "恩送り活動")
                        Divider().frame(height: 40).background(Color.batCardLight)
                        ProfileStatItem(value: "\(appViewModel.reportedCount)", label: "報告完了")
                        Divider().frame(height: 40).background(Color.batCardLight)
                        ProfileStatItem(value: "\(badges.filter { $0.isUnlocked }.count)", label: "バッジ")
                    }
                    .padding(.vertical, 20)
                    .background(Color.batCard)
                    .cornerRadius(18)
                    .padding(.horizontal)

                    // バッジ
                    VStack(alignment: .leading, spacing: 14) {
                        Text("アチーブメント")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(badges, id: \.title) { badge in
                                    BadgeItem(emoji: badge.emoji, title: badge.title, isUnlocked: badge.isUnlocked)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // メニュー
                    VStack(spacing: 2) {
                        MenuRow(icon: "pencil.circle.fill", title: "プロフィール編集", color: Color.batSecondary, action: {})
                        MenuRow(icon: "gearshape.fill", title: "設定", color: Color.batPrimary, action: {})
                        MenuRow(icon: "questionmark.circle.fill", title: "ヘルプ & FAQ", color: Color.batAccent, action: {})
                        MenuRow(icon: "rectangle.portrait.and.arrow.right.fill", title: "ログアウト", color: .red) {
                            showLogoutAlert = true
                        }
                    }
                    .background(Color.batCard)
                    .cornerRadius(18)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("ログアウト", isPresented: $showLogoutAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("ログアウト", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("ログアウトしますか？")
        }
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.batTextPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.batTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct BadgeItem: View {
    let emoji: String
    let title: String
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 60, height: 60)
                .background(isUnlocked ? Color.batAccent.opacity(0.15) : Color.batCardLight)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isUnlocked ? Color.batAccent.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
                .opacity(isUnlocked ? 1 : 0.4)

            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isUnlocked ? Color.batTextPrimary : Color.batTextSecondary)
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(Color.batTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.batTextSecondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthViewModel())
}
