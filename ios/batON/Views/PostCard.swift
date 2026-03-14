import SwiftUI

struct PostCard: View {
    let post: Post
    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー（投稿者情報と時間）
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.batPrimary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String((post.userName ?? "ユーザー").prefix(1)))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.batPrimary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName ?? "ユーザー")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.batTextPrimary)
                    Text(post.createdAtString)
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }

                Spacer()

                // ポストタイプバッジ
                HStack(spacing: 4) {
                    Text(post.type.icon)
                        .font(.system(size: 12))
                    Text(post.type.displayName)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(post.type == .help_offer ? Color.batSecondary : Color.batAccent)
            }

            // タイトル
            Text(post.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.batTextPrimary)
                .lineLimit(2)

            // 説明文
            Text(post.description)
                .font(.system(size: 13))
                .foregroundColor(Color.batTextSecondary)
                .lineLimit(3)

            // タグ（カテゴリなど）
            if !post.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(post.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.batPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.batPrimary.opacity(0.1))
                            .cornerRadius(12)
                    }
                    if post.tags.count > 3 {
                        Text("+\(post.tags.count - 3)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.batTextSecondary)
                    }
                    Spacer()
                }
            }

            // 場所情報
            if let location = post.location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.batSecondary)
                    Text(location)
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }
            }

            // フッター（いいね・コメント）
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Button {
                        isLiked.toggle()
                    } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                            .foregroundColor(isLiked ? Color.batPrimary : Color.batTextSecondary)
                    }
                    Text("\(post.likesCount)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.batTextSecondary)
                    Text("\(post.commentsCount)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }

                Spacer()

                // ステータスバッジ
                Text(post.status.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .batCard()
    }

    private var statusColor: Color {
        switch post.status {
        case .open: return Color.batSecondary
        case .matched: return Color.batPrimary
        case .completed: return Color.batAccent
        case .closed: return Color.batTextSecondary
        }
    }
}

#Preview {
    VStack {
        PostCard(post: Post(
            id: "1",
            userId: "user1",
            userName: "田中太郎",
            type: .help_offer,
            title: "プログラミング教えます",
            description: "Swiftでアプリ開発を教えられます。初心者向けから応用まで対応可能です。",
            category: "IT",
            tags: ["Swift", "iOS", "プログラミング"],
            location: "東京都渋谷区",
            status: .open,
            likesCount: 42,
            commentsCount: 5,
            createdAt: Date()
        ))
    }
    .padding()
    .background(Color.batBackground)
}
