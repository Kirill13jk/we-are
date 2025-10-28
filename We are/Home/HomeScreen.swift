// HomeScreen.swift
import SwiftUI


// MARK: - Главный экран
struct HomeScreen: View {
    // Передаём список компаний извне (по умолчанию demo)
    var companies: [Company] = Company.demoList

    // Демо-лента. В реальном проекте — подгрузка из сети
    @State private var posts: [FeedPost] = []
    
    @EnvironmentObject private var notifications: NotificationsStore

    @State private var search = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Поиск
                    SearchField(text: $search, placeholder: "Поиск курсов")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Секция компаний: горизонтальный скролл + "Все"
                    CompaniesSection(
                        title: "Компании",
                        companies: filteredCompanies,
                        allCompanies: companies
                    )

                    // Лента постов
                    VStack(spacing: 16) {
                        ForEach(posts.indices, id: \.self) { i in
                            PostCard(post: $posts[i])
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 12)
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
                    .padding(.trailing, 6)   // небольшой безопасный зазор
                }
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

// MARK: - Поисковая строка
private struct SearchField: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
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

// MARK: - Шапка секции компаний + горизонтальная карусель
private struct CompaniesSection: View {
    var title: String
    var companies: [Company]
    var allCompanies: [Company]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                Spacer()
                NavigationLink {
                    AllCompaniesView(companies: allCompanies)
                } label: {
                    Text("Все")
                        .font(.callout)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(companies) { company in
                        NavigationLink {
                            // Если у тебя есть собственный экран компании — он откроется тут
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

// Кружок-аватар компании с подписью
private struct CompanyAvatar: View {
    var name: String
    var logoAsset: String?

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let n = logoAsset, ImageAsset.exists(n) {
                    Image(n).resizable().scaledToFill()
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

// MARK: - Карточка поста
private struct PostCard: View {
    @Binding var post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Хедер: логотип, название
            HStack(spacing: 10) {
                CompanyAvatarSmall(name: post.company.name, logoAsset: post.company.logoAsset)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.company.name).font(.headline)
                    Text(post.timeAgo).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { post.isSaved.toggle() } label: {
                    Image(systemName: "bookmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Фото
            PostImage(imageName: post.imageName)

            // Экшены
            HStack(spacing: 16) {
                Button { post.isLiked.toggle(); if post.isLiked { post.likes += 1 } else { post.likes = max(0, post.likes-1) } } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        Text("\(post.likes)")
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                // индикатор страниц «…» декоративный
                HStack(spacing: 6) {
                    Circle().frame(width: 6, height: 6)
                    Circle().frame(width: 6, height: 6).opacity(0.35)
                    Circle().frame(width: 6, height: 6).opacity(0.35)
                }
                .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            // Текст
            Text(post.text)
                .lineLimit(2)
                .foregroundStyle(.primary)
                .font(.subheadline)

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
    }
}

private struct CompanyAvatarSmall: View {
    var name: String
    var logoAsset: String?

    var body: some View {
        ZStack {
            if let n = logoAsset, ImageAsset.exists(n) {
                Image(n).resizable().scaledToFill()
            } else {
                Image(systemName: "building.2")
                    .resizable().scaledToFit()
                    .padding(6)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 36, height: 36)
        .background(Color(.systemBackground))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))
    }
}

private struct PostImage: View {
    var imageName: String?

    var body: some View {
        Group {
            if let n = imageName, ImageAsset.exists(n) {
                Image(n).resizable().scaledToFill()
            } else {
                // Плейсхолдер
                ZStack {
                    Rectangle().fill(Color(.secondarySystemBackground))
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(4/3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// Кнопка с колокольчиком и бейджем
private struct BellButton: View {
    var badge: Int = 0
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.title3)
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Capsule().fill(.red))
                        .offset(x: 8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Уведомления")
    }
}

// MARK: - Модели ленты (демо)
struct FeedPost: Identifiable {
    let id = UUID()
    let company: Company
    let imageName: String?
    var text: String
    var likes: Int
    var timeAgo: String
    var isLiked: Bool = false
    var isSaved: Bool = false
}

extension FeedPost {
    static func demo(companies: [Company]) -> [FeedPost] {
        var result: [FeedPost] = []
        let imgs = ["post-1", "post-2", "post-3"] // добавь ассеты при желании
        for (i, c) in companies.enumerated().prefix(6) {
            result.append(
                FeedPost(
                    company: c,
                    imageName: imgs.indices.contains(i) ? imgs[i] : nil,
                    text: "Идеальная формула для тех, кто любит брать от жизни всё! Подробнее в посте…",
                    likes: Int.random(in: 50...240),
                    timeAgo: ["2 часа назад", "вчера", "3 дня назад"].randomElement()!
                )
            )
        }
        return result
    }
}
