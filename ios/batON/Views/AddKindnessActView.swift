import SwiftUI

struct AddKindnessActView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedBenefactorId: String = ""
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: KindnessCategory = .other
    @State private var actDate = Date()
    @State private var recipientName = ""
    @State private var errorMessage = ""

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
                        Text("活動を記録")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    VStack(spacing: 20) {

                        // 恩人選択
                        VStack(alignment: .leading, spacing: 8) {
                            Text("誰の恩に報いますか？")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            if appViewModel.benefactors.isEmpty {
                                Text("先に恩人を登録してください")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.batTextSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.batCard)
                                    .cornerRadius(12)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(appViewModel.benefactors) { b in
                                            BenefactorChip(
                                                benefactor: b,
                                                isSelected: selectedBenefactorId == b.id
                                            ) {
                                                selectedBenefactorId = b.id
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 1)
                                }
                            }
                        }

                        // タイトル
                        BatTextField(label: "活動タイトル", text: $title, placeholder: "例：友人に数学を教えた")

                        // 説明
                        VStack(alignment: .leading, spacing: 8) {
                            Text("詳細（任意）")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            TextEditor(text: $description)
                                .foregroundColor(Color.batTextPrimary)
                                .frame(minHeight: 80)
                                .padding(12)
                                .background(Color.batCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.batCardLight, lineWidth: 1)
                                )
                        }

                        // カテゴリ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("カテゴリ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(KindnessCategory.allCases, id: \.rawValue) { cat in
                                    CategoryChip(
                                        category: cat,
                                        isSelected: selectedCategory == cat
                                    ) {
                                        selectedCategory = cat
                                    }
                                }
                            }
                        }

                        // 受益者名
                        BatTextField(label: "誰を助けましたか？", text: $recipientName, placeholder: "例：田中さん")

                        // 日付
                        VStack(alignment: .leading, spacing: 8) {
                            Text("日付")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.batTextSecondary)
                            DatePicker("", selection: $actDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.batCard)
                                .cornerRadius(12)
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Color.batPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        BatPrimaryButton(title: "記録する", icon: "checkmark.circle.fill") {
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
        guard !title.isEmpty else { errorMessage = "タイトルを入力してください"; return }
        guard !selectedBenefactorId.isEmpty else { errorMessage = "恩人を選択してください"; return }
        guard !recipientName.isEmpty else { errorMessage = "受益者を入力してください"; return }

        appViewModel.addKindnessAct(
            benefactorId: selectedBenefactorId,
            title: title,
            description: description,
            category: selectedCategory,
            actDate: actDate,
            recipientName: recipientName
        )
        presentationMode.wrappedValue.dismiss()
    }
}

struct BenefactorChip: View {
    let benefactor: Benefactor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(benefactor.avatarColor.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(benefactor.initial)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(benefactor.avatarColor)
                    )
                Text(benefactor.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color.batTextPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? LinearGradient.batPrimaryGradient : LinearGradient(colors: [Color.batCard, Color.batCard], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.clear : Color.batCardLight, lineWidth: 1)
            )
        }
    }
}

struct CategoryChip: View {
    let category: KindnessCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(category.icon)
                    .font(.system(size: 20))
                Text(category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color.batTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? LinearGradient.batPrimaryGradient : LinearGradient(colors: [Color.batCard, Color.batCard], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.batCardLight, lineWidth: 1)
            )
        }
    }
}
