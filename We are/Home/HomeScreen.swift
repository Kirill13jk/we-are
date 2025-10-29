import SwiftUI

// MARK: - Главный экран (только компании)
struct HomeScreen: View {
    var companies: [Company] = Company.demoList

    @EnvironmentObject private var notifications: NotificationsStore
    @State private var search = ""
    
    @State private var posts: [Post] = Post.demo

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Поиск
                SearchField(text: $search, placeholder: "Поиск курсов")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Контейнер компаний: заголовок + горизонтальный скролл + "Все"
                CompaniesSection(
                    title: "Компании",
                    companies: filteredCompanies,
                    allCompanies: companies
                )
                
                NewsSection(posts: $posts)
                    .padding(.top, 8)
            }
        }
        .navigationTitle("Главная")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    NotificationsScreen()
                } label: {
                    BellBadge(count: notifications.unreadCount)
                }
                .padding(.trailing, 6)
            }
        }
    }

    // Фильтрация компаний по поиску
    private var filteredCompanies: [Company] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return companies }
        return companies.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }
}

private struct CompanyLogoCircle: View {
    var logoAsset: String?

    var body: some View {
        ZStack {
            if let n = logoAsset, ImageAsset.exists(n) { // если нет утилиты exists — убери проверку
                Image(n)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "building.2.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 36, height: 36)            // компактный размер
        .clipShape(Circle())                      // делает изображение круглым
        .overlay(Circle().stroke(Color(.separator), lineWidth: 0.8))  // тонкая окантовка
        .background(Circle().fill(Color(.systemBackground)))          // белый фон под логотип
    }
}


// MARK: - Поисковая строка
private struct SearchField: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Секция компаний + горизонтальная карусель
private struct CompaniesSection: View {
    var title: String
    var companies: [Company]
    var allCompanies: [Company]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.title3).foregroundStyle(Color.accentColor)
                Spacer()
                NavigationLink("Все") {
                    AllCompaniesView(companies: allCompanies)
                }
                .font(.callout)
                .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(companies) { company in
                        NavigationLink {
                            CompanyScreen(company: company)
                        } label: {
                            CompanyAvatar(name: company.name, logoAsset: company.logoAsset)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// Кружок-аватар компании с подписью (без UIKit-проверок)
private struct CompanyAvatar: View {
    var name: String
    var logoAsset: String?

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let n = logoAsset, !n.isEmpty {
                    Image(n).resizable().scaledToFill()   // убедись, что ассет есть в Assets
                } else {
                    Image(systemName: "building.2")
                        .resizable().scaledToFit()
                        .padding(10)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 58, height: 58)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))

            Text(name)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(width: 72)
        }
    }
}


// MARK: - News Section
private struct NewsSection: View {
    @Binding var posts: [Post]

    var body: some View {
        VStack(spacing: 12) {
            ForEach($posts) { $post in
                PostCard(post: $post)
                    .padding(.horizontal, 16)
            }
            Spacer(minLength: 8)
        }
    }
}

// MARK: - Post Card
private struct PostCard: View {
    @Binding var post: Post
    @State private var page = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 8) {
                CompanyLogoCircle(logoAsset: post.company.logoAsset)
                    .padding(.trailing, 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.company.name).font(.headline)
                    Text(post.company.category).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "ellipsis").foregroundStyle(.secondary)
            }

            // Images pager
            ZStack(alignment: .bottom) {
                TabView(selection: $page) {
                    ForEach(Array(post.images.enumerated()), id: \.offset) { idx, name in
                        Group {
                            if ImageAsset.exists(name) {
                                Image(name).resizable().scaledToFill()
                            } else {
                                RoundedRectangle(cornerRadius: 0).fill(Color(.systemGray5))
                                    .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary))
                            }
                        }
                        .tag(idx)
                        .frame(height: 260)
                        .clipped()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // dots
                PageDots(count: post.images.count, index: page)
                    .padding(.bottom, 10)
            }

            // Actions
            HStack(spacing: 14) {
                Button {
                    post.liked.toggle()
                    post.likes += post.liked ? 1 : -1
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.liked ? "heart.fill" : "heart")
                        Text("\(post.likes)")
                    }
                    .font(.headline)
                }

                Spacer()

                Button {
                    post.saved.toggle()
                } label: {
                    Image(systemName: post.saved ? "bookmark.fill" : "bookmark")
                        .font(.headline)
                }
            }
            .tint(.primary)

            // Caption + time
            Text(post.text)
                .font(.subheadline)
                .lineLimit(2)

            Text(post.date, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

// MARK: - Page Dots
private struct PageDots: View {
    var count: Int
    var index: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(count, 1), id: \.self) { i in
                Circle()
                    .fill(i == index ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
