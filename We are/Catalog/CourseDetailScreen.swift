// CourseDetailScreen.swift
import SwiftUI
import Foundation

private enum CourseDetailTab { case about, modules, reviews }

struct CourseDetailScreen: View {
    let course: CourseItem

    @State private var tab: CourseDetailTab = .about
    @State private var showReviewSheet = false
    @State private var showThanks = false

    // Динамическая модель экрана
    @State private var detail: CourseDetailModel

    init(course: CourseItem) {
        self.course = course
        _detail = State(initialValue: CourseDetailLoader.load(for: course))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Header с иллюстрацией и play
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemPink).opacity(0.18))
                        .frame(height: 180)
                        .overlay(
                            Group {
                                if let n = detail.imageAsset, ImageAsset.exists(n) {
                                    Image(n).resizable().scaledToFit()
                                } else if let n = course.imageAsset, ImageAsset.exists(n) {
                                    Image(n).resizable().scaledToFit()
                                } else {
                                    Image(systemName: "text.book.closed")
                                        .font(.system(size: 72, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20),
                            alignment: .topLeading
                        )

                    NavigationLink {
                        LessonStartView(courseTitle: course.title)
                    } label: {
                        ZStack {
                            Circle().fill(Color(.systemBackground))
                                .frame(width: 94, height: 94)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                            Circle().fill(Color.accentColor)
                                .frame(width: 80, height: 80)
                                .overlay(Image(systemName: "play.fill").foregroundStyle(.white))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16)
                    .offset(y: 28)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Название
                Text("\(detail.title)")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 28)
                    .padding(.horizontal, 16)

                // Табы
                TabsBar(selected: $tab)
                    .padding(.top, 12)

                // Контент табов
                Group {
                    switch tab {
                    case .about:
                        AboutTab(text: detail.about, hours: detail.durationHours)
                    case .modules:
                        ModulesTab(modules: detail.modules, imageName: detail.imageAsset ?? course.imageAsset)
                    case .reviews:
                        ReviewsTab(
                            ratingAverage: detail.ratingAverage,
                            ratingBreakdown: detail.ratingBreakdown,
                            reviews: detail.reviews,
                            openForm: { showReviewSheet = true }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReviewSheet) {
            ReviewFormSheet(
                courseTitle: detail.title,
                imageName: detail.imageAsset ?? course.imageAsset,
                onSubmit: { rating, text in
                    // обновим локальную модель
                    withAnimation {
                        detail.reviews.insert(.init(author: "Вы", text: text, dateString: DateFormatter.review.string(from: Date()), rating: rating), at: 0)
                        detail.recalcRating()
                    }
                    showThanks = true
                }
            )
            .presentationDetents([.large])
        }
        .overlay {
            if showThanks {
                ThanksOverlay { showThanks = false }
            }
        }
    }
}

// MARK: - Модель экрана (динамика)

private struct CourseDetailModel {
    var title: String
    var imageAsset: String?
    var about: String
    var durationHours: Int
    var modules: [Module]
    var reviews: [Review]
    var ratingAverage: Double
    var ratingBreakdown: [Int: Int] // ключ = 1…5

    struct Module: Identifiable, Codable {
        let id: UUID
        let idx: Int
        let title: String
        let subtitle: String
        init(id: UUID = UUID(), idx: Int, title: String, subtitle: String) {
            self.id = id; self.idx = idx; self.title = title; self.subtitle = subtitle
        }
    }

    struct Review: Identifiable, Codable {
        let id: UUID
        let author: String
        let text: String
        let dateString: String
        let rating: Int
        init(id: UUID = UUID(), author: String, text: String, dateString: String, rating: Int) {
            self.id = id; self.author = author; self.text = text; self.dateString = dateString; self.rating = rating
        }
    }

    mutating func recalcRating() {
        let counts = Dictionary(grouping: reviews, by: { $0.rating }).mapValues(\.count)
        ratingBreakdown = [1,2,3,4,5].reduce(into: [:]) { $0[$1] = counts[$1] ?? 0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        ratingAverage = reviews.isEmpty ? 0 : Double(sum) / Double(reviews.count)
    }

    // Заглушка, если нет JSON
    static func sample(title: String, image: String?, lessons: Int) -> CourseDetailModel {
        let mods = (1...max(1, min(8, lessons))).map {
            Module(idx: $0, title: "Название урока \($0)", subtitle: "Lorem ipsum dolor sit amet")
        }
        let revs: [Review] = [
            .init(author: "Виктор", text: "Lorem ipsum dolor sit amet, consectetur adipiscing…", dateString: "03.03.2022 / 10:30", rating: 5),
            .init(author: "Дарья", text: loremShort, dateString: "03.03.2022 / 10:30", rating: 4)
        ]
        var m = CourseDetailModel(
            title: title,
            imageAsset: image,
            about: loremLong,
            durationHours: 18,
            modules: mods,
            reviews: revs,
            ratingAverage: 0,
            ratingBreakdown: [:]
        )
        m.recalcRating()
        return m
    }
}

// DTO для JSON
private struct CourseDetailDTO: Codable {
    var title: String
    var image: String?
    var about: String
    var durationHours: Int
    var modules: [CourseDetailModel.Module]
    var reviews: [CourseDetailModel.Review]
    var ratingAverage: Double?
    var ratingBreakdown: [Int: Int]?
}

private enum CourseDetailLoader {
    // Маппинг названия карточки → ключ JSON
    static let lookup: [String: String] = [
        "Курсы English": "english",
        "Курсы “SMM”": "smm",
        "Курсы “Лидерства”": "leadership"
    ]

    static func load(for course: CourseItem) -> CourseDetailModel {
        let key = lookup[course.title] ?? fallbackKey(from: course.title)
        if let url = Bundle.main.url(forResource: "course_\(key)", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let dto = try? JSONDecoder().decode(CourseDetailDTO.self, from: data) {

            var model = CourseDetailModel(
                title: dto.title,
                imageAsset: dto.image ?? course.imageAsset,
                about: dto.about,
                durationHours: dto.durationHours,
                modules: dto.modules,
                reviews: dto.reviews,
                ratingAverage: dto.ratingAverage ?? 0,
                ratingBreakdown: dto.ratingBreakdown ?? [:]
            )
            // если в JSON не было статистики — посчитаем
            if dto.ratingAverage == nil || dto.ratingBreakdown == nil {
                model.recalcRating()
            }
            return model
        }

        // Fallback — заглушка из карточки каталога
        return CourseDetailModel.sample(title: course.title, image: course.imageAsset, lessons: course.lessons)
    }

    // Бэкап-ключ, если нет явного соответствия
    private static func fallbackKey(from title: String) -> String {
        let ascii = title.folding(options: .diacriticInsensitive, locale: .current)
        let slug = ascii.replacingOccurrences(of: "[^A-Za-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
            .lowercased()
        return slug.isEmpty ? "default" : slug
    }
}

// MARK: - Tabs bar

private struct TabsBar: View {
    @Binding var selected: CourseDetailTab

    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "О курсе", isOn: selected == .about) { selected = .about }
            TabButton(title: "Модули", isOn: selected == .modules) { selected = .modules }
            TabButton(title: "Отзывы", isOn: selected == .reviews) { selected = .reviews }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }

    private struct TabButton: View {
        let title: String
        let isOn: Bool
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundStyle(isOn ? .primary : .secondary)
                    Capsule()
                        .fill(isOn ? Color.accentColor : .clear)
                        .frame(height: 3)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tab: О курсе

private struct AboutTab: View {
    var text: String
    var hours: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(text)
                .foregroundStyle(.secondary)

            Divider().opacity(0.2)

            HStack(spacing: 10) {
                Image(systemName: "clock")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Примерное время прохождения курса")
                        .font(.subheadline)
                    Text("\(hours) часов")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Tab: Модули

private struct ModulesTab: View {
    var modules: [CourseDetailModel.Module]
    var imageName: String?

    var body: some View {
        VStack(spacing: 18) {
            ForEach(modules) { m in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 88, height: 64)
                        .overlay {
                            if let n = imageName, ImageAsset.exists(n) {
                                Image(n).resizable().scaledToFit().padding(6)
                            } else {
                                Image(systemName: "photo").foregroundStyle(.secondary)
                            }
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(m.idx).  \(m.title)")
                            .font(.system(size: 22))
                        Text(m.subtitle)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Circle()
                        .fill(Color(.secondarySystemFill))
                        .frame(width: 34, height: 34)
                        .overlay(Image(systemName: "chevron.right"))
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color(.systemBackground)))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(.separator), lineWidth: 0.5))
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Tab: Отзывы

private struct ReviewsTab: View {
    var ratingAverage: Double
    var ratingBreakdown: [Int: Int]
    var reviews: [CourseDetailModel.Review]
    var openForm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading) {
                    Text(String(format: "%.1f", ratingAverage))
                        .font(.system(size: 36, weight: .bold))
                    StarsRow(rating: ratingAverage)
                        .padding(.top, 2)
                    Text("из 5").font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach((1...5).reversed(), id: \.self) { star in
                        HStack(spacing: 8) {
                            Text("\(star)").font(.footnote).foregroundStyle(.secondary)
                                .frame(width: 14, alignment: .trailing)
                            Rectangle()
                                .fill(Color(.secondarySystemFill))
                                .frame(width: 140, height: 8)
                                .clipShape(Capsule())
                            Text("\(ratingBreakdown[star] ?? 0)")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Button(action: openForm) {
                Text("Оставьте отзыв")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
            }
            .padding(.top, 6)

            Text("\(reviews.count) отзыв\(reviews.count == 1 ? "" : "а") о курсе")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)

            ForEach(reviews) { r in
                ReviewCard(name: r.author, text: r.text, date: r.dateString)
            }
        }
    }

    private struct ReviewCard: View {
        var name: String
        var text: String
        var date: String
        @State private var isExpanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle().fill(Color(.secondarySystemFill)).frame(width: 36, height: 36)
                        .overlay(Image(systemName: "person.fill"))
                    Text(name).font(.headline)
                    Spacer()
                    Text(date).font(.footnote).foregroundStyle(.secondary)
                }

                Text(isExpanded ? text : String(text.prefix(120)) + (text.count > 120 ? "…" : ""))
                    .foregroundStyle(.secondary)

                HStack {
                    Button {
                        withAnimation { isExpanded.toggle() }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down").foregroundStyle(Color.accentColor)
                    }
                    Spacer()
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        }
    }
}

// MARK: - Review form

private struct ReviewFormSheet: View {
    var courseTitle: String
    var imageName: String?
    var onSubmit: (_ rating: Int, _ text: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 4
    @State private var text: String = "Отличный курс, спасибо!"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color(.secondarySystemFill))
                            .frame(width: 92, height: 92)
                            .overlay {
                                if let n = imageName, ImageAsset.exists(n) {
                                    Image(n).resizable().scaledToFit().clipShape(Circle()).padding(8)
                                } else {
                                    Image(systemName: "text.book.closed.fill").font(.title)
                                }
                            }
                        Text("Курсы “\(courseTitle)”")
                            .font(.title3)
                            .padding(.horizontal, 16)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.accentColor.opacity(0.12)))

                    VStack(spacing: 14) {
                        Text("Поставьте оценку").foregroundStyle(.secondary)
                        StarsInput(rating: $rating)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(.separator), lineWidth: 0.5))

                    TextEditor(text: $text)
                        .frame(minHeight: 140)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
                }
                .padding(16)
            }
            .navigationTitle("Оставьте отзыв")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Оценить") {
                        onSubmit(rating, text)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Thanks overlay

private struct ThanksOverlay: View {
    var onClose: () -> Void
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.green).frame(width: 72, height: 72)
                    Image(systemName: "checkmark").font(.title).foregroundStyle(.white)
                }
                Text("Спасибо!").font(.title3).foregroundStyle(.green)
                Text("Ваш отзыв успешно отправлен")
                    .foregroundStyle(.secondary)
                Button("Закрыть") { onClose() }
                    .padding(.top, 6)
            }
            .padding(22)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
            .padding(.horizontal, 36)
            .scaleEffect(animate ? 1 : 0.9)
            .onAppear {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { animate = true }
            }
        }
    }
}

// MARK: - Small helpers

private struct StarsRow: View {
    var rating: Double
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < Int(round(rating)) ? "star.fill" : "star")
                    .foregroundStyle(i < Int(round(rating)) ? Color.yellow : Color(.systemGray3))
            }
        }
    }
}

private struct StarsInput: View {
    @Binding var rating: Int
    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(i <= rating ? Color.yellow : Color(.systemGray3))
                    .onTapGesture { rating = i }
            }
        }
    }
}

private let loremShort = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra habitant lacus, auctor nulla nec cursus nascetur."
private let loremLong = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra habitant lacus, auctor nulla nec cursus nascetur. Sed elit, duis justo, neque mauris. Blandit tristique blandit est integer urna, aliquet. Suspendisse dignissim condimentum sit arcu egestas purus. Placerat mi volutpat tellus amet vestibulum. Tortor sed arcu gravida sed varius pellentesque tincidunt odio. Sit massa sit tellus molestie odio lectus senectus morbi lacus. Lacus, velit interdum est sed. Ullamcorper neque dignissim nibh elit id. Congue auctor eu dui volutpat cursus. Pellentesque nunc eleifend egestas praesent aliquam.
"""

private extension DateFormatter {
    static let review: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy / HH:mm"
        return f
    }()
}
