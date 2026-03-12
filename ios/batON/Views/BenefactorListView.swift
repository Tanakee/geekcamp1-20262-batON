import SwiftUI

struct BenefactorListView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showAddBenefactor = false

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("恩人")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Spacer()
                    Button { showAddBenefactor = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.batPrimary)
                    }
                }
                .padding()

                if appViewModel.benefactors.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("🤝")
                            .font(.system(size: 48))
                        Text("まだ恩人がいません")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.batTextSecondary)
                        Text("+ ボタンからお世話になった人を登録しましょう")
                            .font(.system(size: 13))
                            .foregroundColor(Color.batTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(appViewModel.benefactors) { benefactor in
                                BenefactorCard(benefactor: benefactor)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddBenefactor) {
            AddBenefactorView()
                .environmentObject(appViewModel)
        }
    }
}

struct BenefactorCard: View {
    let benefactor: Benefactor

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(benefactor.avatarColor.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(benefactor.avatarColor, lineWidth: 2))
                    .overlay(
                        Text(benefactor.initial)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(benefactor.avatarColor)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(benefactor.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)
                    Text(benefactor.relation)
                        .font(.system(size: 12))
                        .foregroundColor(Color.batTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(benefactor.kindnessActCount)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(benefactor.avatarColor)
                    Text("件の恩送り")
                        .font(.system(size: 10))
                        .foregroundColor(Color.batTextSecondary)
                }
            }

            Text("「\(benefactor.kindnessDescription)」")
                .font(.system(size: 13))
                .foregroundColor(Color.batTextSecondary)
                .italic()
                .lineLimit(2)

            Divider().background(Color.batCardLight)

            HStack {
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 12))
                        Text("報告を送る")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(benefactor.avatarColor)
                }
            }
        }
        .padding(18)
        .background(Color.batCard)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    BenefactorListView()
        .environmentObject(AppViewModel())
}
