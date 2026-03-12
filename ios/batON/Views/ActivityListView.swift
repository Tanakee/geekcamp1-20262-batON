import SwiftUI

struct ActivityListView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showAddAct = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("活動記録")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                    Button { showAddAct = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.batPrimary)
                    }
                }
                .padding()

                if appViewModel.kindnessActs.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("✨")
                            .font(.system(size: 48))
                        Text("まだ活動がありません")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.batTextSecondary)
                        Text("+ ボタンから最初の恩送りを記録しましょう")
                            .font(.system(size: 13))
                            .foregroundColor(Color.batTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(appViewModel.actsByMonth, id: \.0) { month, acts in
                                Text(month)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.batTextSecondary)
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                                ForEach(acts) { act in
                                    ActivityCard(act: act)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddAct) {
            AddKindnessActView()
                .environmentObject(appViewModel)
        }
    }
}

struct ActivityCard: View {
    let act: KindnessAct

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.batPrimary.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(act.category.icon)
                        .font(.system(size: 22))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(act.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.batTextPrimary)
                HStack(spacing: 8) {
                    CategoryBadge(title: act.category.rawValue)
                    Text(act.dateString)
                        .font(.system(size: 11))
                        .foregroundColor(Color.batTextSecondary)
                }
            }

            Spacer()

            StatusBadge(status: act.statusText)
        }
        .padding(16)
        .background(Color.batCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
}

#Preview {
    ActivityListView()
        .environmentObject(AppViewModel())
}
