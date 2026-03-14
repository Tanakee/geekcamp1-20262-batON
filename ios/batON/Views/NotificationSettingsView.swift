import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var settings: NotificationSettings?
    @State private var isLoading = false

    @State private var matchNotifications = true
    @State private var messageNotifications = true
    @State private var postLikeNotifications = true
    @State private var postCommentNotifications = true
    @State private var followNotifications = true
    @State private var skillMatchNotifications = true

    @State private var startHour: Double = 8
    @State private var endHour: Double = 22

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.batTextSecondary)
                            .font(.system(size: 18, weight: .medium))
                            .frame(width: 36, height: 36)
                            .background(Color.batCard)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("通知設定")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.batCard)

                ScrollView {
                    VStack(spacing: 24) {

                        // 通知の種類
                        VStack(spacing: 12) {
                            Text("通知設定")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)

                            VStack(spacing: 0) {
                                NotificationToggleRow(
                                    icon: "heart.fill",
                                    title: "マッチング通知",
                                    isOn: $matchNotifications
                                )
                                NotificationToggleRow(
                                    icon: "bubble.right.fill",
                                    title: "メッセージ通知",
                                    isOn: $messageNotifications
                                )
                                NotificationToggleRow(
                                    icon: "hand.thumbsup.fill",
                                    title: "いいね通知",
                                    isOn: $postLikeNotifications
                                )
                                NotificationToggleRow(
                                    icon: "bubble.left.fill",
                                    title: "コメント通知",
                                    isOn: $postCommentNotifications
                                )
                                NotificationToggleRow(
                                    icon: "person.badge.plus.fill",
                                    title: "フォロー通知",
                                    isOn: $followNotifications
                                )
                                NotificationToggleRow(
                                    icon: "checkmark.circle.fill",
                                    title: "スキルマッチ通知",
                                    isOn: $skillMatchNotifications
                                )
                            }
                            .background(Color.batCard)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }

                        // 通知時間帯
                        VStack(spacing: 12) {
                            Text("通知時間帯")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.batTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)

                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("開始時刻")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.batTextPrimary)
                                        Spacer()
                                        Text("\(String(format: "%02d", Int(startHour))):00")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.batPrimary)
                                    }
                                    Slider(value: $startHour, in: 0...23, step: 1)
                                        .tint(Color.batPrimary)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("終了時刻")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.batTextPrimary)
                                        Spacer()
                                        Text("\(String(format: "%02d", Int(endHour))):00")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.batPrimary)
                                    }
                                    Slider(value: $endHour, in: 0...23, step: 1)
                                        .tint(Color.batPrimary)
                                }
                            }
                            .padding(16)
                            .background(Color.batCard)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }

                        // 保存ボタン
                        VStack {
                            if isLoading {
                                ProgressView()
                                    .tint(Color.batPrimary)
                                    .frame(height: 52)
                            } else {
                                BatPrimaryButton(title: "保存する", icon: "checkmark") {
                                    saveSettings()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        // TODO: GraphQL query で現在の設定を取得
        // モック実装
        matchNotifications = true
        messageNotifications = true
        postLikeNotifications = true
        postCommentNotifications = true
        followNotifications = true
        skillMatchNotifications = true
        startHour = 8
        endHour = 22
    }

    private func saveSettings() {
        isLoading = true
        // TODO: GraphQL mutation で設定を保存
        // モック実装
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            dismiss()
        }
    }
}

struct NotificationToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.batPrimary)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color.batTextPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color.batPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.batCard)
        .overlay(
            Divider()
                .offset(y: 22),
            alignment: .bottom
        )
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthViewModel())
}
