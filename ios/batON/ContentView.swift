import SwiftUI

enum Tab {
    case home, feed, chain, matching, profile
}

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Tab = .home
    @State private var showChain = false
    @State private var showConversations = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // メインコンテンツ
            Group {
                switch selectedTab {
                case .home:
                    NavigationView { DashboardView() }
                case .feed:
                    NavigationView { FeedView() }
                case .chain:
                    Color.clear // 中央ボタンはシートで開く
                case .matching:
                    NavigationView { SearchView() }
                case .profile:
                    NavigationView { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80) // タブバーの高さ分

            // カスタムタブバー
            CustomTabBar(selectedTab: $selectedTab, showChain: $showChain, unreadCount: appViewModel.unreadMessageCount)
        }
        .environmentObject(appViewModel)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            appViewModel.loadFromAPI(userId: authViewModel.currentUserId)
            appViewModel.loadPosts()
        }
        .onChange(of: authViewModel.currentUserId) { newId in
            appViewModel.loadFromAPI(userId: newId)
            appViewModel.loadPosts()
        }
        .fullScreenCover(isPresented: $showChain) {
            ChainFullScreenView()
                .environmentObject(appViewModel)
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showConversations) {
            NavigationView {
                ConversationsView()
                    .environmentObject(appViewModel)
                    .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - カスタムタブバー
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var showChain: Bool
    var unreadCount: Int = 0

    var body: some View {
        ZStack {
            // タブバー背景
            HStack(spacing: 0) {
                TabBarItem(icon: "house.fill", label: "ホーム", tab: .home, selectedTab: $selectedTab)
                TabBarItem(icon: "sparkles", label: "フィード", tab: .feed, selectedTab: $selectedTab)

                // 中央ボタンのスペース
                Color.clear.frame(width: 72)

                TabBarItem(icon: "heart.fill", label: "マッチング", tab: .matching, selectedTab: $selectedTab, badge: unreadCount)
                TabBarItem(icon: "person.fill", label: "プロフィール", tab: .profile, selectedTab: $selectedTab)
            }
            .frame(height: 64)
            .background(
                Color.batCard
                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: -4)
            )

            // 中央の感謝チェーンボタン
            VStack(spacing: 0) {
                Button {
                    showChain = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.batPrimaryGradient)
                            .frame(width: 64, height: 64)
                            .shadow(color: Color.batPrimary.opacity(0.6), radius: 14, x: 0, y: 4)

                        VStack(spacing: 2) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("チェーン")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .offset(y: -20)

                Spacer().frame(height: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: 64, alignment: .center)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let tab: Tab
    @Binding var selectedTab: Tab
    var badge: Int = 0

    var isSelected: Bool { selectedTab == tab }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? Color.batPrimary : Color.batTextSecondary)

                    if badge > 0 {
                        Text(badge > 99 ? "99+" : "\(badge)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 10, y: -6)
                    }
                }
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? Color.batPrimary : Color.batTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 感謝チェーンフルスクリーン
struct ChainFullScreenView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            GratitudeChain3DView(userName: authViewModel.currentUserName.isEmpty ? "あなた" : authViewModel.currentUserName)
                .environmentObject(appViewModel)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.batTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.batCard)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
            }
            .padding(.top, 56)
            .padding(.leading, 20)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
