import SwiftUI

struct SendReportView: View {
    let act: KindnessAct
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var message = ""
    @State private var isSending = false

    var benefactor: Benefactor? { appViewModel.benefactor(for: act.benefactorId) }

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // ヘッダー
                    HStack {
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.batTextSecondary)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 36, height: 36)
                                .background(Color.batCard)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("報告を送る")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    VStack(spacing: 20) {

                        // 宛先カード
                        if let b = benefactor {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(b.avatarColor.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .overlay(Circle().stroke(b.avatarColor, lineWidth: 2))
                                    .overlay(
                                        Text(b.initial)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(b.avatarColor)
                                    )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("宛先")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.batTextSecondary)
                                    Text(b.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color.batTextPrimary)
                                    Text(b.relation)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.batTextSecondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.batCard)
                            .cornerRadius(16)
                        }

                        // 活動内容
                        VStack(alignment: .leading, spacing: 6) {
                            Text("報告する活動")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            HStack(spacing: 10) {
                                Text(act.category.icon)
                                    .font(.system(size: 20))
                                Text(act.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.batTextPrimary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.batCard)
                            .cornerRadius(12)
                        }

                        // メッセージ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メッセージ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            TextEditor(text: $message)
                                .foregroundColor(Color.batTextPrimary)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(Color.batCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.batCardLight, lineWidth: 1)
                                )
                            if message.isEmpty {
                                Text("例：「\(benefactor?.name ?? "")さんのおかげで、誰かの力になれました。」")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.batTextSecondary)
                                    .italic()
                            }
                        }

                        BatPrimaryButton(
                            title: isSending ? "送信中…" : "報告を送る",
                            icon: isSending ? "hourglass" : "paperplane.fill"
                        ) {
                            send()
                        }
                        .disabled(isSending || message.isEmpty)
                        .opacity(isSending || message.isEmpty ? 0.7 : 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private func send() {
        guard !message.isEmpty else { return }
        isSending = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        let b = benefactor
        appViewModel.sendReport(
            for: act,
            benefactorName: b.map { "\($0.name)（\($0.relation)）" } ?? "",
            message: message
        )
        presentationMode.wrappedValue.dismiss()
    }
}
