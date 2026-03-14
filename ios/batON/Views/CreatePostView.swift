import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var postType: PostType = .help_offer
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var location: String = ""
    @State private var tags: [String] = []
    @State private var currentTag: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil

    let categories = ["IT", "教育", "ビジネス", "クリエイティブ", "ライフスタイル", "エンターテイメント", "その他"]

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !category.isEmpty
    }

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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.batTextSecondary)
                            .frame(width: 44, height: 44)
                            .background(Color.batCardLight)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("新規投稿")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.batTextPrimary)

                    Spacer()

                    Button {
                        createPost()
                    } label: {
                        Text(isSaving ? "投稿中…" : "投稿する")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(isFormValid && !isSaving ? Color.batPrimary : Color.batTextSecondary.opacity(0.4))
                            .cornerRadius(18)
                    }
                    .disabled(!isFormValid || isSaving)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.batCard)

                ScrollView {
                    VStack(spacing: 20) {
                        // ポストタイプ選択
                        VStack(alignment: .leading, spacing: 8) {
                            Text("投稿タイプ")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            HStack(spacing: 12) {
                                ForEach(PostType.allCases, id: \.self) { type in
                                    Button {
                                        postType = type
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(type.icon)
                                                .font(.system(size: 24))
                                            Text(type.displayName)
                                                .font(.system(size: 11, weight: .semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(postType == type ? Color.batPrimary.opacity(0.2) : Color.batCard)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(postType == type ? Color.batPrimary : Color.clear, lineWidth: 2)
                                        )
                                    }
                                    .foregroundColor(Color.batTextPrimary)
                                }
                            }
                        }

                        // タイトル入力
                        VStack(alignment: .leading, spacing: 8) {
                            Text("タイトル")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            TextField("投稿のタイトルを入力", text: $title)
                                .padding(12)
                                .background(Color.batCard)
                                .cornerRadius(12)
                                .font(.system(size: 14))
                        }

                        // 説明文入力
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("説明")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color.batTextPrimary)

                                Spacer()

                                Text("\(description.count)/500")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.batTextSecondary)
                            }

                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.batCard)
                                .cornerRadius(12)
                                .font(.system(size: 14))
                        }

                        // カテゴリ選択
                        VStack(alignment: .leading, spacing: 8) {
                            Text("カテゴリ")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    Button {
                                        category = cat
                                    } label: {
                                        Text(cat)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(category == cat ? .white : Color.batTextSecondary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(category == cat ? Color.batPrimary : Color.batCard)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(category == cat ? Color.batPrimary : Color.clear, lineWidth: 1.5)
                                            )
                                    }
                                }
                            }
                        }

                        // 場所情報
                        VStack(alignment: .leading, spacing: 8) {
                            Text("場所（オプション）")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            TextField("東京都渋谷区", text: $location)
                                .padding(12)
                                .background(Color.batCard)
                                .cornerRadius(12)
                                .font(.system(size: 14))
                        }

                        // タグ入力
                        VStack(alignment: .leading, spacing: 8) {
                            Text("タグ（最大5個）")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.batTextPrimary)

                            HStack {
                                TextField("タグを追加してEnter", text: $currentTag)
                                    .padding(12)
                                    .background(Color.batCard)
                                    .cornerRadius(12)
                                    .font(.system(size: 14))
                                    .onSubmit {
                                        addTag()
                                    }

                                if !currentTag.isEmpty {
                                    Button(action: addTag) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color.batPrimary)
                                    }
                                }
                            }

                            if !tags.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                                        HStack(spacing: 6) {
                                            Text(tag)
                                                .font(.system(size: 12, weight: .semibold))
                                            Button {
                                                tags.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10, weight: .semibold))
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.batPrimary.opacity(0.15))
                                        .cornerRadius(16)
                                        .foregroundColor(Color.batPrimary)
                                    }
                                }
                            }
                        }

                        if let error = errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.batTextPrimary)
                            }
                            .padding(12)
                            .background(Color.batCard)
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func addTag() {
        let trimmed = currentTag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, tags.count < 5, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        currentTag = ""
    }

    private func createPost() {
        guard isFormValid else { return }

        isSaving = true
        errorMessage = nil

        let type = postType == .help_offer ? "help_offer" : "help_request"

        appViewModel.createPost(
            type: type,
            title: title,
            description: description,
            category: category,
            tags: tags,
            location: location.isEmpty ? nil : location
        )

        // フィードバック
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        // 少し遅延させて画面を閉じる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - FlowLayout（タグ用）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            let x = result.frames[index].minX + bounds.minX
            let y = result.frames[index].minY + bounds.minY
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var maxHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth, currentX > 0 {
                    currentX = 0
                    currentY += maxHeight + spacing
                    maxHeight = 0
                }
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                maxHeight = max(maxHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + maxHeight)
        }
    }
}

#Preview {
    CreatePostView()
        .environmentObject(AppViewModel())
        .environmentObject(AuthViewModel())
}
