import SwiftUI

struct FeedView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedFilter: String = "all"
    @State private var isRefreshing = false

    var filteredPosts: [Post] {
        guard !appViewModel.posts.isEmpty else { return [] }
        switch selectedFilter {
        case "offer":
            return appViewModel.posts.filter { $0.type == .help_offer }
        case "request":
            return appViewModel.posts.filter { $0.type == .help_request }
        default:
            return appViewModel.posts
        }
    }

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                VStack(alignment: .leading, spacing: 12) {
                    Text("フィード")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)

                    // フィルタータブ
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "すべて", isSelected: selectedFilter == "all") {
                                selectedFilter = "all"
                            }
                            FilterChip(label: "教えます", isSelected: selectedFilter == "offer") {
                                selectedFilter = "offer"
                            }
                            FilterChip(label: "教えて", isSelected: selectedFilter == "request") {
                                selectedFilter = "request"
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
                .background(Color.batCard)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

                // ポスト一覧
                if appViewModel.isLoadingData {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Text("フィードを読み込み中…")
                            .font(.system(size: 13))
                            .foregroundColor(Color.batTextSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredPosts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(Color.batTextSecondary)
                        Text("投稿がありません")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.batTextPrimary)
                        Text("新しい投稿が増えるのを待ちましょう")
                            .font(.system(size: 13))
                            .foregroundColor(Color.batTextSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(filteredPosts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await refreshFeed()
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .overlay(errorBanner, alignment: .top)
        .onAppear {
            appViewModel.loadPosts()
        }
    }

    private func refreshFeed() async {
        await MainActor.run {
            isRefreshing = true
        }
        appViewModel.loadPosts()
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            isRefreshing = false
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

// MARK: - フィルタータブコンポーネント
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color.batTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.batPrimary : Color.batCard)
                .cornerRadius(20)
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AppViewModel())
}
