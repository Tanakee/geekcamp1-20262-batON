import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @State private var messages: [Message] = [
        Message(id: "m1", conversationId: "c1", senderId: "u1", senderName: "田中太郎", content: "こんにちは！", readAt: Date(), createdAt: Date().addingTimeInterval(-7200)),
        Message(id: "m2", conversationId: "c1", senderId: "u2", senderName: "あなた", content: "こんにちは！", readAt: Date(), createdAt: Date().addingTimeInterval(-7000)),
        Message(id: "m3", conversationId: "c1", senderId: "u1", senderName: "田中太郎", content: "プログラミングを教えていただきたいのですが...", readAt: Date(), createdAt: Date().addingTimeInterval(-6900)),
        Message(id: "m4", conversationId: "c1", senderId: "u2", senderName: "あなた", content: "もちろんです！いつがいいですか？", readAt: Date(), createdAt: Date().addingTimeInterval(-6000)),
        Message(id: "m5", conversationId: "c1", senderId: "u1", senderName: "田中太郎", content: "ありがとうございます！", readAt: nil, createdAt: Date().addingTimeInterval(-3600)),
    ]
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // チャットヘッダー
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.batTextSecondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(conversation.otherUserName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.batTextPrimary)
                        Text("オンライン")
                            .font(.system(size: 11))
                            .foregroundColor(Color.batTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(Color.batTextSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.batCard)

                // メッセージ表示
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            if message.senderId == "u2" {
                                // 自分のメッセージ
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(message.content)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.batPrimary)
                                            .cornerRadius(16)

                                        Text(message.timeString)
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.batTextSecondary)
                                            .padding(.horizontal, 12)
                                    }
                                    .padding(.trailing, 16)
                                }
                            } else {
                                // 相手のメッセージ
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(message.content)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.batTextPrimary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.batCard)
                                            .cornerRadius(16)

                                        Text(message.timeString)
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.batTextSecondary)
                                            .padding(.leading, 12)
                                    }
                                    .padding(.leading, 16)

                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }

                // メッセージ入力
                HStack(spacing: 8) {
                    TextField("メッセージを入力...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 13))
                        .padding(.horizontal, 16)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(inputText.isEmpty ? Color.batTextSecondary : Color.batPrimary)
                    }
                    .disabled(inputText.isEmpty)
                    .padding(.trailing, 16)
                }
                .padding(.vertical, 12)
                .background(Color.batCard)
            }
        }
        .navigationBarHidden(true)
    }

    private func sendMessage() {
        let newMessage = Message(
            id: UUID().uuidString,
            conversationId: conversation.id,
            senderId: "u2",
            senderName: "あなた",
            content: inputText,
            readAt: nil,
            createdAt: Date()
        )
        messages.append(newMessage)
        inputText = ""
    }
}

#Preview {
    ChatView(conversation: Conversation(id: "c1", user1Id: "u1", user2Id: "u2", user1Name: "田中太郎", user2Name: "あなた", lastMessageText: "ありがとうございます！", lastMessageAt: Date(), unreadCount: 0))
}
