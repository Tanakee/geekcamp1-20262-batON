import SwiftUI

struct MatchingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0

    var matchingUsers: [Post] {
        appViewModel.posts.filter { $0.status == .open }.prefix(10).map { $0 }
    }

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Text("マッチング")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.batCard)

                if matchingUsers.isEmpty {
                    emptyState
                } else {
                    ZStack {
                        ForEach(0..<matchingUsers.count, id: \.self) { index in
                            if index >= currentIndex {
                                MatchingCard(
                                    post: matchingUsers[index],
                                    isTop: index == currentIndex,
                                    offset: index == currentIndex ? offset : 0
                                )
                                .offset(y: CGFloat(index - currentIndex) * 10)
                                .zIndex(Double(matchingUsers.count - index))
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation.width
                            }
                            .onEnded { value in
                                if value.translation.width > 100 {
                                    // Swipe right (Like)
                                    withAnimation(.easeInOut) {
                                        currentIndex += 1
                                    }
                                } else if value.translation.width < -100 {
                                    // Swipe left (Pass)
                                    withAnimation(.easeInOut) {
                                        currentIndex += 1
                                    }
                                }
                                offset = 0
                            }
                    )

                    // ボタン
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.easeInOut) {
                                currentIndex += 1
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }

                        Button {
                            withAnimation(.easeInOut) {
                                currentIndex += 1
                            }
                        } label: {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.batPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundColor(Color.batTextSecondary)
            Text("マッチング相手がいません")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.batTextPrimary)
            Text("新しい投稿を待ちましょう")
                .font(.system(size: 13))
                .foregroundColor(Color.batTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - マッチングカード
struct MatchingCard: View {
    let post: Post
    let isTop: Bool
    let offset: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ユーザー情報
            HStack(spacing: 12) {
                Circle()
                    .fill(LinearGradient.batPrimaryGradient)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String((post.userName ?? "U").prefix(1)))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(post.userName ?? "ユーザー")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text("4.8")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.batTextPrimary)
                    }
                }

                Spacer()

                HStack(spacing: 2) {
                    Text(post.type.icon)
                        .font(.system(size: 14))
                    Text(post.type.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(post.type == .help_offer ? Color.batSecondary : Color.batAccent)
            }

            Divider().background(Color.batCardLight)

            // ポスト内容
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.batTextPrimary)

                Text(post.description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.batTextSecondary)
                    .lineLimit(3)

                if let category = post.category {
                    HStack(spacing: 6) {
                        Text(category)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.batPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.batPrimary.opacity(0.1))
                            .cornerRadius(8)

                        if !post.tags.isEmpty {
                            ForEach(post.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.batTextSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.batCard)
                                    .cornerRadius(6)
                            }
                        }

                        Spacer()
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.batCard)
        .cornerRadius(16)
        .shadow(color: Color.batPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
        .offset(x: isTop ? offset * 0.3 : 0)
        .rotationEffect(.degrees(isTop ? Double(offset) * 0.02 : 0), anchor: .center)
    }
}

#Preview {
    MatchingView()
        .environmentObject(AppViewModel())
}
