import SwiftUI

struct ReportListView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("報告")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.batTextPrimary)
                    .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // 報告待ちセクション
                        let pending = appViewModel.kindnessActs.filter { !$0.isReported }
                        if !pending.isEmpty {
                            SectionHeader(title: "報告待ち", count: pending.count)
                            ForEach(pending) { act in
                                PendingReportCard(act: act)
                            }
                        }

                        // 報告済みセクション
                        if !appViewModel.completedReports.isEmpty {
                            SectionHeader(title: "報告済み", count: appViewModel.completedReports.count)
                                .padding(.top, 8)
                            ForEach(appViewModel.completedReports) { report in
                                ReportCard2(report: report)
                            }
                        }

                        if pending.isEmpty && appViewModel.completedReports.isEmpty {
                            VStack(spacing: 12) {
                                Text("📬")
                                    .font(.system(size: 48))
                                Text("まだ報告はありません")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.batTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.batTextSecondary)
            Text("\(count)")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color.batCardLight)
                .foregroundColor(Color.batTextSecondary)
                .cornerRadius(6)
        }
    }
}

struct PendingReportCard: View {
    let act: KindnessAct
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showSendReport = false

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.batAccent.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "clock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.batAccent)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(act.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.batTextPrimary)
                if let b = appViewModel.benefactor(for: act.benefactorId) {
                    Text("宛先: \(b.name)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.batTextSecondary)
                }
                Text(act.dateString)
                    .font(.system(size: 11))
                    .foregroundColor(Color.batTextSecondary)
            }

            Spacer()

            Button { showSendReport = true } label: {
                Text("報告する")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(LinearGradient.batPrimaryGradient)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.batCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $showSendReport) {
            SendReportView(act: act)
                .environmentObject(appViewModel)
        }
    }
}

struct ReportCard2: View {
    let report: Report

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.batSecondary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.batSecondary)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(report.activityTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.batTextPrimary)
                Text("宛先: \(report.benefactorName)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.batTextSecondary)
                Text(report.dateString)
                    .font(.system(size: 11))
                    .foregroundColor(Color.batTextSecondary)
            }

            Spacer()

            StatusBadge(status: report.statusText)
        }
        .padding(16)
        .background(Color.batCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ReportListView()
        .environmentObject(AppViewModel())
}
