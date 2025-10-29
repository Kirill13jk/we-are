import SwiftUI

enum CompanyTab: String, CaseIterable { case about = "О компании", reviews = "Отзывы" }

struct CompanyScreen: View {
    @State var company: Company
    @State private var tab: CompanyTab = .about
    @Environment(\.openURL) private var openURL   // вместо UIApplication

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Header
                VStack(spacing: 12) {

                    // 1) Лого + (Название + Курсы) на одной линии, под ним категория
                    HStack(alignment: .center, spacing: 12) {
                        logo
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Text(company.name)
                                    .font(.title2).bold()

                                NavigationLink {
                                    CompanyCoursesScreen(company: company)
                                } label: {
                                    Label("Курсы", systemImage: "briefcase.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.accentColor)
                                        .labelStyle(.titleAndIcon)
                                }
                            }

                            Text(company.category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    // 2) Отдельная карточка на всю ширину: Статистика + Соцсети
                    StatsSocialCard(company: company, openURL: openURL)

                    // 3) Кнопка подписки
                    Button {
                        company.isFollowed.toggle()
                    } label: {
                        Text(company.isFollowed ? "Отменить подписку" : "Подписаться")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundStyle(.white)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Tabs
                VStack(spacing: 8) {
                    HStack {
                        ForEach(CompanyTab.allCases, id: \.self) { t in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { tab = t }
                            } label: {
                                Text(t.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(tab == t ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    ZStack(alignment: tab == .about ? .leading : .trailing) {
                        Rectangle().fill(Color(.separator)).frame(height: 1).opacity(0.6)
                        Capsule().fill(Color.accentColor)
                            .frame(width: 100, height: 3)
                            .padding(.horizontal, 16)
                            .animation(.easeInOut(duration: 0.2), value: tab)
                    }
                }
                .padding(.horizontal, 16)

                // Content
                Group {
                    switch tab {
                    case .about: aboutView
                    case .reviews: reviewsView
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 16)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: About
    private var aboutView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(company.about)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(3)

            Divider().opacity(0.6)

            // Контакты
            VStack(alignment: .leading, spacing: 12) {
                Text("Контакты :").font(.headline)
                if let p1 = company.contacts.phone1 { ContactRow(icon: "phone.fill", text: p1) }
                if let p2 = company.contacts.phone2 { ContactRow(icon: "phone", text: p2) }
                if let addr = company.contacts.address { ContactRow(icon: "mappin.and.ellipse", text: addr) }
            }

            Divider().opacity(0.6)

            // Новости — заголовок + "Все"
            HStack {
                Text("Новости").font(.headline)
                Spacer()
                Button("Все") { /* TODO */ }
                    .font(.subheadline)
            }
            
            // В CompanyScreen.aboutView
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(company.news) { item in
                    Image(item.imageAsset)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 106)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

        }
    }

    // MARK: Reviews
    private var reviewsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Сводка рейтинга + гистограмма
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", company.rating))
                        .font(.system(size: 40, weight: .bold))
                    Text("из 5").foregroundStyle(.secondary)
                }
                VStack(spacing: 6) {
                    ForEach((1...5).reversed(), id: \.self) { stars in
                        HStack(spacing: 8) {
                            Text("\(stars)")
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            ProgressView(value: progress(for: stars))
                                .frame(height: 6)
                                .tint(.accentColor)
                            Text("\(count(for: stars))")
                                .frame(width: 26, alignment: .trailing)
                        }
                        .font(.caption)
                    }
                }
            }

            Button { /* TODO: форма отзыва */ } label: {
                Text("Оставьте отзыв")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .foregroundStyle(.white)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Text("\(company.reviews.count) отзыва(ов) о курсе")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(company.reviews) { review in
                    ReviewCard(review: review)
                }
            }
        }
    }

    // MARK: Helpers (картинки + статистика)
    private var logo: some View {
        Group {
            if let n = company.logoAsset {
                Image(n).resizable().scaledToFill()
            } else {
                Image(systemName: "building.2.crop.circle.fill")
                    .resizable().scaledToFill()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var cover: some View {
        Group {
            if let n = company.coverAsset {
                Image(n).resizable().scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
            }
        }
        .clipped()
    }

    private func stat(value: Int, title: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)").font(.headline)
            Text(title).foregroundStyle(.secondary)
        }
    }

    private func count(for stars: Int) -> Int {
        let idx = 5 - stars
        return (0..<company.histogram.count).contains(idx) ? company.histogram[idx] : 0
    }
    private func progress(for stars: Int) -> Double {
        let c = count(for: stars)
        let total = max(company.histogram.reduce(0, +), 1)
        return Double(c) / Double(total)
    }
}

// MARK: Вспомогательные вью

private struct StatsSocialCard: View {
    var company: Company
    var openURL: OpenURLAction

    var body: some View {
        VStack(spacing: 14) {
            // Статистика
            HStack(spacing: 40) {
                Spacer()
                stat(value: company.posts, title: "Публикации")
                    .frame(width: 120) // фикс ширины для ровного центра
                stat(value: company.followers, title: "Подписчики")
                    .frame(width: 120)
                Spacer()
            }
            .font(.subheadline)
            .padding(.vertical, 8) // ↑ добавили «воздух» сверху/снизу


            // Соцсети (SF Symbols – «стандартные Apple»)
            HStack(spacing: 14) {
                ForEach(company.socials) { link in
                    SocialIcon(type: link.type) {
                        if let u = link.url { openURL(u) }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // локальный helper
    private func stat(value: Int, title: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)").font(.headline)
            Text(title).foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center) // центрируем подпись под числом
    }

}
private struct SocialIcon: View {
    var type: SocialType
    var tap: () -> Void

    var body: some View {
        Button(action: tap) {
            let name: String = {
                switch type {
                case .facebook:  return "globe"            // без бренда
                case .instagram: return "camera"           // стандартная камера
                case .telegram:  return "paperplane"       // бумажный самолётик
                case .website:   return "safari"           // или "globe"
                }
            }()
            Image(systemName: name)
                .font(.title2)
                .frame(width: 44, height: 44)
                .foregroundStyle(Color.accentColor)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct ContactRow: View {
    var icon: String
    var text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).frame(width: 18)
            Text(text)
            Spacer()
        }
        .font(.callout)
    }
}

private struct ReviewCard: View {
    var review: Review
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color(.systemGray4)).frame(width: 28, height: 28)
                    Text(review.author).font(.headline)
                }
                Spacer()
                Text(review.date, style: .date)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < review.rating ? "star.fill" : "star")
                        .foregroundStyle(i < review.rating ? .yellow : .secondary)
                }
            }
            Text(review.text).font(.callout)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}
