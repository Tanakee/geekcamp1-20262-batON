import SwiftUI

struct ConversationsView: View {
    @State private var conversations: [Conversation] = [
        Conversation(id: "c1", user1Id: "u1", user2Id: "u2", user1Name: "田中太郎", user2Name: "あなた", lastMessageText: "ありがとうございます！", lastMessageAt: Date().addingTimeInterval(-3600), unreadCount: 2),
        Conversation(id: "c2", user1Id: "u2", user2Id: "u3", user1Name: "山田花子", user2Name: "あなた", lastMessageText: "了解です", lastMessageAt: Date().addingTimeInterval(-86400), unreadCount: 0),
    ]
    @State private var selectedConversation: Conversation?
    @State private var showNewChat = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Text("メッセージ")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                    Button {
                        showNewChat = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16))
                            .foregroundColor(Color.batTextSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.batCard)

                // 会話一覧
                if conversations.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "メッセージがありません",
                        message: "マッチングした相手とチャットを始めましょう"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(conversations) { conversation in
                                NavigationLink(destination: ChatView(conversation: conversation)) {
                                    ConversationRow(conversation: conversation)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - 会話行
struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.batPrimary.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(conversation.otherUserName.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.batPrimary)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.otherUserName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.batTextPrimary)

                    Spacer()

                    Text(conversation.lastMessageTimeString)
                        .font(.system(size: 12))
                        .foregroundColor(Color.batTextSecondary)
                }

                Text(conversation.lastMessageText ?? "メッセージなし")
                    .font(.system(size: 12))
                    .foregroundColor(Color.batTextSecondary)
                    .lineLimit(1)
            }

            if conversation.unreadCount > 0 {
                Circle()
                    .fill(Color.batPrimary)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(12)
        .background(Color.batCard)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    ConversationsView()
}
