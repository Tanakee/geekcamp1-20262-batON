import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var searchText: String = ""
    @State private var selectedCategory: String = ""
    @State private var selectedType: String = ""
    @State private var searchResults: [Post] = []
    @State private var isSearching: Bool = false

    let categories = ["すべて", "IT", "教育", "ビジネス", "クリエイティブ", "ライフスタイル", "エンターテイメント"]
    let types = ["すべて", "教えます", "教えて"]

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // 検索バー
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.batTextSecondary)

                        TextField("投稿を検索...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: searchText) { newValue in
                                if newValue.isEmpty {
                                    searchResults = []
                                } else {
                                    performSearch()
                                }
                            }
                    }
                    .padding(.horizontal, 16)

                    // フィルタータブ
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // カテゴリフィルタ
                            Menu {
                                Picker("カテゴリ", selection: $selectedCategory) {
                                    ForEach(categories, id: \.self) { cat in
                                        Text(cat).tag(cat)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                    Text(selectedCategory.isEmpty ? "カテゴリ" : selectedCategory)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(selectedCategory.isEmpty ? Color.batTextSecondary : Color.batPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedCategory.isEmpty ? Color.batCard : Color.batPrimary.opacity(0.1))
                                .cornerRadius(16)
                            }

                            // タイプフィルタ
                            Menu {
                                Picker("タイプ", selection: $selectedType) {
                                    ForEach(types, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "line.3.horizontal.decrease")
                                    Text(selectedType.isEmpty ? "タイプ" : selectedType)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(selectedType.isEmpty ? Color.batTextSecondary : Color.batPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedType.isEmpty ? Color.batCard : Color.batPrimary.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(Color.batCard)

                // 検索結果
                if searchText.isEmpty {
                    emptyState
                } else if isSearching {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Text("検索中...")
                            .font(.system(size: 13))
                            .foregroundColor(Color.batTextSecondary)
                        Spacer()
                    }
                } else if searchResults.isEmpty {
                    emptyResults
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(searchResults) { post in
                                SearchResultCard(post: post)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Color.batTextSecondary)
            Text("投稿を検索")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.batTextPrimary)
            Text("キーワードを入力して投稿を見つけましょう")
                .font(.system(size: 13))
                .foregroundColor(Color.batTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyResults: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "nosign")
                .font(.system(size: 48))
                .foregroundColor(Color.batTextSecondary)
            Text("投稿が見つかりません")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.batTextPrimary)
            Text("別のキーワードで検索してみてください")
                .font(.system(size: 13))
                .foregroundColor(Color.batTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func performSearch() {
        isSearching = true
        // TODO: Backend API呼び出し
        // 現在はモックデータで検索をシミュレート
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            searchResults = appViewModel.posts.filter { post in
                let matchesText = post.title.localizedCaseInsensitiveContains(searchText) ||
                                  post.description.localizedCaseInsensitiveContains(searchText)
                let matchesCategory = selectedCategory.isEmpty || selectedCategory == "すべて" || post.category == selectedCategory
                let matchesType = selectedType.isEmpty || selectedType == "すべて" || post.type.rawValue.contains(selectedType)

                return matchesText && matchesCategory && matchesType
            }
            isSearching = false
        }
    }
}

// MARK: - 検索結果カード
struct SearchResultCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.batPrimary.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String((post.userName ?? "U").prefix(1)))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.batPrimary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName ?? "ユーザー")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.batTextPrimary)
                    Text(post.createdAtString)
                        .font(.system(size: 10))
                        .foregroundColor(Color.batTextSecondary)
                }

                Spacer()

                HStack(spacing: 2) {
                    Text(post.type.icon)
                    Text(post.type.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(post.type == .help_offer ? Color.batSecondary : Color.batAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    post.type == .help_offer ?
                    Color.batSecondary.opacity(0.1) :
                    Color.batAccent.opacity(0.1)
                )
                .cornerRadius(8)
            }

            Text(post.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.batTextPrimary)
                .lineLimit(2)

            Text(post.description)
                .font(.system(size: 12))
                .foregroundColor(Color.batTextSecondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                if let category = post.category {
                    Text(category)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.batPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.batPrimary.opacity(0.1))
                        .cornerRadius(8)
                }

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                    Text("\(post.likesCount)")
                        .font(.system(size: 10))
                }
                .foregroundColor(Color.batTextSecondary)

                Spacer()
            }
        }
        .padding(12)
        .batCard()
    }
}

#Preview {
    SearchView()
        .environmentObject(AppViewModel())
}
