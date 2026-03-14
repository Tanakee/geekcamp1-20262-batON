import SwiftUI

// MARK: - ダミーレーティング（発表用）
private let mockRatings: [Double] = [4.8, 4.5, 4.9, 4.2, 4.7]

struct MatchingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0
    @State private var swipingRight: Bool = false
    @State private var showMatchModal: Bool = false
    @State private var matchedPost: Post? = nil
    @State private var cardExitOffset: CGFloat = 0

    var matchingPosts: [Post] {
        appViewModel.posts.filter { $0.status == .open }.prefix(10).map { $0 }
    }

    var currentPost: Post? {
        guard currentIndex < matchingPosts.count else { return nil }
        return matchingPosts[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Text("マッチング")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                    Text("\(max(0, matchingPosts.count - currentIndex))件")
                        .font(.system(size: 13))
                        .foregroundColor(Color.batTextSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.batCard)

                if matchingPosts.isEmpty || currentIndex >= matchingPosts.count {
                    emptyState
                } else {
                    // カードスタック
                    ZStack {
                        ForEach((currentIndex..<min(currentIndex + 3, matchingPosts.count)).reversed(), id: \.self) { index in
                            let stackDepth = index - currentIndex
                            MatchingCard(
                                post: matchingPosts[index],
                                rating: mockRatings[index % mockRatings.count],
                                isTop: stackDepth == 0,
                                offset: stackDepth == 0 ? offset : 0,
                                likeOpacity: stackDepth == 0 ? Double(max(0, offset - 40) / 80) : 0,
                                nopeOpacity: stackDepth == 0 ? Double(max(0, -offset - 40) / 80) : 0
                            )
                            .scaleEffect(1.0 - CGFloat(stackDepth) * 0.04)
                            .offset(y: CGFloat(stackDepth) * 12)
                            .zIndex(Double(10 - stackDepth))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation.width
                            }
                            .onEnded { value in
                                if value.translation.width > 100 {
                                    swipeRight()
                                } else if value.translation.width < -100 {
                                    swipeLeft()
                                } else {
                                    withAnimation(.spring()) { offset = 0 }
                                }
                            }
                    )

                    // アクションボタン
                    HStack(spacing: 32) {
                        // パスボタン
                        Button { swipeLeft() } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.batCard)
                                    .frame(width: 68, height: 68)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                Image(systemName: "xmark")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }

                        // ライクボタン
                        Button { swipeRight() } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.batPrimaryGradient)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.batPrimary.opacity(0.5), radius: 12, x: 0, y: 4)
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    .padding(.top, 16)
                }
            }

            // マッチモーダル
            if showMatchModal, let post = matchedPost {
                MatchModal(post: post) {
                    showMatchModal = false
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - スワイプアクション
    private func swipeRight() {
        guard let post = currentPost else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = 600
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            advanceCard()
            offset = 0
            // 50% の確率でマッチ成立（発表用）
            if Bool.random() {
                matchedPost = post
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showMatchModal = true
                }
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
            }
        }
    }

    private func swipeLeft() {
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = -600
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            advanceCard()
            offset = 0
        }
    }

    private func advanceCard() {
        currentIndex += 1
    }

    // MARK: - 空状態
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "heart.slash")
                .font(.system(size: 56))
                .foregroundColor(Color.batTextSecondary.opacity(0.5))
            Text("カードがなくなりました")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.batTextPrimary)
            Text("また後で来るか、フィードに投稿してみましょう")
                .font(.system(size: 14))
                .foregroundColor(Color.batTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                currentIndex = 0
            } label: {
                Text("もう一度")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.batPrimary)
                    .cornerRadius(20)
            }
            .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - マッチングカード
struct MatchingCard: View {
    let post: Post
    let rating: Double
    let isTop: Bool
    let offset: CGFloat
    let likeOpacity: Double
    let nopeOpacity: Double

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 16) {
                // ユーザー情報
                HStack(spacing: 12) {
                    Circle()
                        .fill(LinearGradient.batPrimaryGradient)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text(String((post.userName ?? "U").prefix(1)))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.userName ?? "ユーザー")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)
                        }
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text(post.type.icon)
                            .font(.system(size: 14))
                        Text(post.type.displayName)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(post.type == .help_offer ? Color.batSecondary : Color.batAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background((post.type == .help_offer ? Color.batSecondary : Color.batAccent).opacity(0.1))
                    .cornerRadius(10)
                }

                Divider().background(Color.batCardLight)

                // 投稿内容
                VStack(alignment: .leading, spacing: 10) {
                    Text(post.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)

                    Text(post.description)
                        .font(.system(size: 14))
                        .foregroundColor(Color.batTextSecondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)

                    if let category = post.category {
                        HStack(spacing: 8) {
                            Text(category)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.batPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.batPrimary.opacity(0.12))
                                .cornerRadius(8)

                            ForEach(post.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.batTextSecondary)
                            }
                        }
                    }

                    if let location = post.location {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.batTextSecondary)
                            Text(location)
                                .font(.system(size: 12))
                                .foregroundColor(Color.batTextSecondary)
                        }
                    }
                }

                Spacer()

                // ヒント
                if isTop {
                    HStack {
                        Spacer()
                        Text("← パス　　ライク →")
                            .font(.system(size: 11))
                            .foregroundColor(Color.batTextSecondary.opacity(0.6))
                        Spacer()
                    }
                }
            }
            .padding(20)

            // LIKE / NOPE インジケーター
            HStack {
                // LIKE
                Text("LIKE")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 3))
                    .rotationEffect(.degrees(-15))
                    .opacity(likeOpacity)
                    .padding(.leading, 20)
                    .padding(.top, 24)

                Spacer()

                // NOPE
                Text("NOPE")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 3))
                    .rotationEffect(.degrees(15))
                    .opacity(nopeOpacity)
                    .padding(.trailing, 20)
                    .padding(.top, 24)
            }
        }
        .background(Color.batCard)
        .cornerRadius(20)
        .shadow(color: Color.batPrimary.opacity(isTop ? 0.25 : 0.1), radius: 12, x: 0, y: 6)
        .offset(x: isTop ? offset : 0)
        .rotationEffect(.degrees(isTop ? Double(offset) * 0.03 : 0), anchor: .bottom)
    }
}

// MARK: - マッチ成立モーダル
struct MatchModal: View {
    let post: Post
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                // アニメーション的な装飾
                ZStack {
                    Circle()
                        .fill(LinearGradient.batPrimaryGradient)
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.batPrimary.opacity(0.6), radius: 20, x: 0, y: 0)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }

                VStack(spacing: 8) {
                    Text("マッチング成立！")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                    Text("\(post.userName ?? "相手") さんと\nマッチしました 🎉")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }

                // 相手のカード（ミニ）
                HStack(spacing: 14) {
                    Circle()
                        .fill(LinearGradient.batPrimaryGradient)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(String((post.userName ?? "U").prefix(1)))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.userName ?? "ユーザー")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(post.title)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.white.opacity(0.12))
                .cornerRadius(16)

                VStack(spacing: 12) {
                    Button {
                        onDismiss()
                    } label: {
                        Text("メッセージを送る")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(LinearGradient.batPrimaryGradient)
                            .cornerRadius(26)
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("続けてマッチング")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.batCard)
                    .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }
}

#Preview {
    MatchingView()
        .environmentObject(AppViewModel())
}
