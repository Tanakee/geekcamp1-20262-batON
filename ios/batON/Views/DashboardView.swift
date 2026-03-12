import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddAct = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ヘッダー
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("こんにちは 👋")
                                .font(.system(size: 14))
                                .foregroundColor(Color.batTextSecondary)
                            Text("今日も恩を送ろう")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                        }
                        Spacer()
                        Circle()
                            .fill(LinearGradient.batPrimaryGradient)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(authViewModel.currentUserName.prefix(1)))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // 統計カード
                    HStack(spacing: 12) {
                        StatCard(number: "\(appViewModel.thisMonthActCount)", label: "今月の活動", color: Color.batPrimary)
                        StatCard(number: "\(appViewModel.reportedCount)", label: "報告完了", color: Color.batSecondary)
                        StatCard(number: "\(appViewModel.pendingReportCount)", label: "未報告", color: Color.batAccent)
                    }
                    .padding(.horizontal)

                    // 感謝チェーン
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("感謝チェーン")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                            Spacer()
                            NavigationLink(destination: GratitudeChain3DView()) {
                                Text("詳細 →")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.batSecondary)
                            }
                        }

                        VStack(spacing: 0) {
                            if let first = appViewModel.benefactors.first {
                                ChainNode(name: first.name, role: "恩人", color: Color.batAccent)
                            } else {
                                ChainNode(name: "恩人", role: "恩人", color: Color.batAccent)
                            }
                            ChainArrow()
                            ChainNode(name: authViewModel.currentUserName.isEmpty ? "あなた" : authViewModel.currentUserName, role: "ユーザー", color: Color.batPrimary)
                            ChainArrow()
                            HStack(spacing: 12) {
                                let recentActs = appViewModel.kindnessActs.prefix(3)
                                ForEach(Array(recentActs), id: \.id) { act in
                                    ChainNode(name: act.recipientName, role: "受益者", color: Color.batSecondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .batCard()
                    }
                    .padding(.horizontal)

                    // 最近の活動
                    VStack(alignment: .leading, spacing: 16) {
                        Text("最近の活動")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)

                        ForEach(appViewModel.kindnessActs.prefix(2)) { act in
                            RecentActivityCard(
                                title: act.title,
                                category: act.category.rawValue,
                                date: act.dateString,
                                status: act.statusText
                            )
                        }
                    }
                    .padding(.horizontal)

                    // CTAボタン
                    BatPrimaryButton(
                        title: "新しい活動を記録",
                        icon: "plus.circle.fill",
                        action: { showAddAct = true }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddAct) {
            AddKindnessActView()
                .environmentObject(appViewModel)
        }
    }
}

// MARK: - 統計カード
struct StatCard: View {
    let number: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(number)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.batTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .batCard()
    }
}

// MARK: - チェーンノード
struct ChainNode: View {
    let name: String
    let role: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke(color, lineWidth: 2))
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                )
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.batTextPrimary)
            Text(role)
                .font(.system(size: 10))
                .foregroundColor(Color.batTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - チェーン矢印
struct ChainArrow: View {
    var body: some View {
        LinearGradient.batChainGradient
            .frame(width: 2, height: 32)
            .overlay(
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color.batSecondary)
                    .offset(y: 14)
            )
            .padding(.vertical, 4)
    }
}

// MARK: - 最近の活動カード
struct RecentActivityCard: View {
    let title: String
    let category: String
    let date: String
    let status: String

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.batPrimary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.batPrimary)
                )
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.batTextPrimary)
                HStack(spacing: 8) {
                    CategoryBadge(title: category)
                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }
            }
            Spacer()
            StatusBadge(status: status)
        }
        .padding(16)
        .batCard()
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthViewModel())
}
