import SwiftUI

struct AddBenefactorView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var name = ""
    @State private var relation = ""
    @State private var kindnessDescription = ""
    @State private var errorMessage = ""

    let relationOptions = ["父", "母", "友人", "先生", "先輩", "同僚", "恩師", "その他"]

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
                        Text("恩人を登録")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    VStack(spacing: 20) {

                        // 名前
                        BatTextField(label: "名前", text: $name, placeholder: "例：田中太郎")

                        // 関係性
                        VStack(alignment: .leading, spacing: 8) {
                            Text("関係性")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(relationOptions, id: \.self) { option in
                                        Button {
                                            relation = option
                                        } label: {
                                            Text(option)
                                                .font(.system(size: 13, weight: .medium))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(relation == option ? LinearGradient.batPrimaryGradient : LinearGradient(colors: [Color.batCard, Color.batCard], startPoint: .leading, endPoint: .trailing))
                                                .foregroundColor(relation == option ? .white : Color.batTextSecondary)
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(relation == option ? Color.clear : Color.batCardLight, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                            BatTextField(label: "", text: $relation, placeholder: "その他の場合はここに入力")
                        }

                        // 受けた恩
                        VStack(alignment: .leading, spacing: 8) {
                            Text("受けた恩・きっかけ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            TextEditor(text: $kindnessDescription)
                                .foregroundColor(Color.batTextPrimary)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.batCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.batCardLight, lineWidth: 1)
                                )
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Color.batPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        BatPrimaryButton(title: "登録する", icon: "heart.fill") {
                            save()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private func save() {
        guard !name.isEmpty else { errorMessage = "名前を入力してください"; return }
        guard !relation.isEmpty else { errorMessage = "関係性を入力してください"; return }
        guard !kindnessDescription.isEmpty else { errorMessage = "受けた恩を入力してください"; return }

        appViewModel.addBenefactor(name: name, relation: relation, kindnessDescription: kindnessDescription)
        presentationMode.wrappedValue.dismiss()
    }
}
