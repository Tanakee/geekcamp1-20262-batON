import SwiftUI

struct ProfileView: View {
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
                            Text("田")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.batPrimary.opacity(0.3), lineWidth: 4)
                                .scaleEffect(1.15)
                        )

                        VStack(spacing: 4) {
                            Text("田中太郎")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                            Text("tanaka.taro@email.com")
                                .font(.system(size: 13))
                                .foregroundColor(Color.batTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)

                    // 統計
                    HStack(spacing: 0) {
                        ProfileStatItem(value: "3", label: "恩送り活動")
                        Divider().frame(height: 40).background(Color.batCardLight)
                        ProfileStatItem(value: "2", label: "報告完了")
                        Divider().frame(height: 40).background(Color.batCardLight)
                        ProfileStatItem(value: "2", label: "バッジ")
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
                                BadgeItem(emoji: "🌱", title: "初恩送り", isUnlocked: true)
                                BadgeItem(emoji: "⭐", title: "5回達成", isUnlocked: true)
                                BadgeItem(emoji: "🔥", title: "10回達成", isUnlocked: false)
                                BadgeItem(emoji: "🌟", title: "全カテゴリ", isUnlocked: false)
                                BadgeItem(emoji: "💎", title: "30日連続", isUnlocked: false)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // メニュー
                    VStack(spacing: 2) {
                        MenuRow(icon: "pencil.circle.fill", title: "プロフィール編集", color: Color.batSecondary)
                        MenuRow(icon: "gearshape.fill", title: "設定", color: Color.batPrimary)
                        MenuRow(icon: "questionmark.circle.fill", title: "ヘルプ & FAQ", color: Color.batAccent)
                        MenuRow(icon: "rectangle.portrait.and.arrow.right.fill", title: "ログアウト", color: .red)
                    }
                    .background(Color.batCard)
                    .cornerRadius(18)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
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

    var body: some View {
        Button(action: {}) {
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
}
