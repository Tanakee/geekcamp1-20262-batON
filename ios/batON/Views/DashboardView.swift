import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddAct = false
    @State private var showConversations = false

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
                            Text(authViewModel.currentUserName.isEmpty ? "今日も恩を送ろう" : "\(authViewModel.currentUserName)さん")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                        }
                        Spacer()

                        // DM ボタン
                        Button {
                            showConversations = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bubble.right.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.batTextSecondary)
                                    .frame(width: 44, height: 44)
                                    .background(Color.batCard)
                                    .clipShape(Circle())

                                if appViewModel.unreadMessageCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                        .padding(.trailing, 8)

                        Circle()
                            .fill(LinearGradient.batPrimaryGradient)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(authViewModel.currentUserName.prefix(1).isEmpty ? "?" : authViewModel.currentUserName.prefix(1)))
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
                            Text("下のボタンから3D表示")
                                .font(.system(size: 12))
                                .foregroundColor(Color.batTextSecondary)
                        }

                        VStack(spacing: 0) {
                            // 恩人（最大3人まで横並び）
                            if appViewModel.benefactors.isEmpty {
                                ChainNode(name: "恩人未登録", role: "恩人", color: Color.batAccent)
                            } else {
                                HStack(spacing: 12) {
                                    ForEach(Array(appViewModel.benefactors.prefix(3))) { b in
                                        ChainNode(name: b.name, role: "恩人", color: Color.batAccent)
                                    }
                                }
                            }
                            ChainArrow()
                            ChainNode(name: authViewModel.currentUserName.isEmpty ? "あなた" : authViewModel.currentUserName, role: "ユーザー", color: Color.batPrimary)
                            ChainArrow()
                            // 受益者（重複排除 + 最大3人まで）
                            let uniqueRecipients = Array(
                                Dictionary(grouping: appViewModel.kindnessActs, by: { $0.recipientName })
                                    .keys.prefix(3)
                            )
                            if uniqueRecipients.isEmpty {
                                ChainNode(name: "受益者未記録", role: "受益者", color: Color.batSecondary)
                            } else {
                                HStack(spacing: 12) {
                                    ForEach(uniqueRecipients, id: \.self) { name in
                                        ChainNode(name: name, role: "受益者", color: Color.batSecondary)
                                    }
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
        .sheet(isPresented: $showConversations) {
            NavigationView {
                ConversationsView()
                    .environmentObject(appViewModel)
                    .environmentObject(authViewModel)
            }
        }
        .overlay(loadingOverlay)
        .overlay(errorBanner, alignment: .top)
        .animation(.easeInOut(duration: 0.3), value: appViewModel.apiError)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if appViewModel.isLoadingData {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("データを読み込み中…")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(Color.batCard.opacity(0.95))
                .cornerRadius(20)
            }
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let error = appViewModel.apiError {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(Color.batTextPrimary)
                Spacer()
                Button { appViewModel.apiError = nil } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.batTextSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.batCard)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
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
