// CatalogScreen.swift
import SwiftUI

struct CatalogScreen: View {
    @State private var search = ""
    @State private var activeTag: String? = nil

    private let sideInset: CGFloat = 16
    
    @State private var showSwitcher = false
    @State private var pushMyCourses = false

    @State private var pushNewList = false
    @State private var pushPopularList = false
    
    @State private var showFilters = false
    @State private var filters = FilterSettings()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Поиск + фильтр (единая панель)
                    HStack(spacing: 10) {
                        // Поле поиска
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Поиск курсов", text: $search)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .overlay(alignment: .trailing) {
                                    if !search.isEmpty {
                                        Button {
                                            search = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .imageScale(.medium)
                                                .foregroundStyle(.secondary)
                                                .padding(.trailing, 6)
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))

                        // Кнопка фильтров
                        Button { showFilters = true } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, sideInset)

                    if isSearching || activeTag != nil {
                        SearchResultsList(
                            query: search,
                            results: searchResults,
                            clear: {
                                // Сброс всего
                                search = ""
                                activeTag = nil
                                filters.category = nil
                            },
                            showClear: true            // ← добавили флаг
                        )
                        .padding(.horizontal, sideInset)
                    } else {

                        // Баннер «Все компании…»
                        BannerAllCompanies()
                            .padding(.horizontal, sideInset)

                        // Часто ищут
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill").foregroundStyle(.red)
                                Text("Часто ищут").font(.headline)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(hotTags, id: \.self) { tag in
                                        TagPill(text: tag, isSelected: tag == activeTag)   // было: tag == selectedTag
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    activeTag = (activeTag == tag ? nil : tag) // было: selectedTag = tag
                                                    search = ""
                                                    filters.category = nil
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.horizontal, 16)


                        // Новые курсы
                        SectionHeaderRow(title: "Новые курсы", actionTitle: "Все") { pushNewList = true }
                        VStack(spacing: 12) {
                            ForEach(CourseItem.newCourses) { course in
                                NavigationLink { CourseDetailScreen(course: course) } label: {
                                    CourseRowCard(course: course)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, sideInset)

                        // Популярные курсы — 2 колонки
                        SectionHeaderRow(title: "Популярные курсы", actionTitle: "Все") { pushPopularList = true }
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(CourseItem.popularCourses) { course in
                                NavigationLink { CourseDetailScreen(course: course) } label: {
                                    CourseTileCard(course: course)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, sideInset)
                    }

                    Spacer(minLength: 16)

                }
                .padding(.vertical, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        showSwitcher = true
                    } label: {
                        HStack(spacing: 6) {
                            Text("Каталог курсов").font(.headline)
                                .foregroundStyle(Color.accentColor)
                            Image(systemName: "chevron.down")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .confirmationDialog("", isPresented: $showSwitcher, titleVisibility: .hidden) {
                Button("Каталог курсов") { /* уже здесь — ничего */ }
                Button("Мои курсы")      { pushMyCourses = true }
                Button("Отменить", role: .cancel) { }
            }
            .navigationDestination(isPresented: $pushMyCourses) {
                MyCoursesScreen(initialTab: .current)
            }
            
            // Навигация по кнопкам "Все"
            .navigationDestination(isPresented: $pushNewList) {
                NewCoursesListScreen()                          // ← экран №2 из твоего примера
            }
            .navigationDestination(isPresented: $pushPopularList) {
                PopularCoursesListScreen()                      // ← экран №3 из твоего примера
            }
            // ⬇️ системный bottom sheet с фильтрами
            .sheet(isPresented: $showFilters) {
                FilterSheet(
                    filters: $filters,
                    onApply: { showFilters = false /* тут можешь запустить реальное применение фильтра */ }
                )
                .presentationDetents([.height(420), .medium])  // как на макете
                .presentationDragIndicator(.visible)
            }

            
        }
    }

    private var isSearching: Bool {
        !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }


    /// Все курсы одной лентой для поиска
    private var allCourses: [CourseItem] {
        // если будут дубликаты — можно дедуплицировать по id/title
        CourseItem.newCourses + CourseItem.popularCourses
    }
    
    /// Горячие теги для блока «Часто ищут»
    private var hotTags: [String] {
        Array(Set(allCourses.map { $0.tag })).sorted()
    }

    private func matches(_ c: CourseItem) -> Bool {
        // 1) фильтр по тегу: берём активный тег из «Часто ищут»,
        //    если его нет — из фильтра (если ты используешь FilterSheet)
        let category = activeTag ?? filters.category
        if let cat = category, !cat.isEmpty, c.tag.normalized != cat.normalized {
            return false
        }

        // 2) фильтр по тексту (поиск)
        let q = search.normalized
        guard !q.isEmpty else { return true }
        return c.title.normalized.contains(q) || c.tag.normalized.contains(q)
    }


    private var searchResults: [CourseItem] {
        allCourses.filter { matches($0) }
    }
}

// Экран «Новые курсы»
struct NewCoursesListScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(CourseItem.newCourses) { course in
                    NavigationLink {
                        CourseDetailScreen(course: course)
                    } label: {
                        CourseRowCard(course: course)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Новые курсы")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Экран «Популярные курсы»
struct PopularCoursesListScreen: View {

    // Можно взять из БД/сервиса. Здесь — статический массив с прогрессом.
    private let items: [(course: CourseItem, progress: Double)] = [
        (.init(title: "Курсы English",
               tag: "Английский",
               lessons: 10,
               imageAsset: "course-english",
               tileTint: nil), 0.87),
        (.init(title: "Курсы SMM",
               tag: "SMM",
               lessons: 15,
               imageAsset: "course-smm",
               tileTint: nil), 0.45),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    NavigationLink {
                        CourseDetailScreen(course: item.course)
                    } label: {
                        // Используем твою карточку с прогрессом
                        CurrentCourseCard(
                            title: item.course.title,
                            tag: item.course.tag,
                            lessons: item.course.lessons,
                            progress: item.progress,
                            image: item.course.imageAsset ?? "mycourse-current-1"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Популярные курсы")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Banner

private struct BannerAllCompanies: View {
    var height: CGFloat = 110

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Левая половина — текст + кнопка
            VStack(alignment: .leading, spacing: 10) {
                Text("Все компании в\nодном приложении")
                    .font(.headline)
                Spacer()
                Button("Подробнее") { }
                    .font(.subheadline)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height)

            // Правая половина — картинка
            Group {
                if ImageAsset.exists("banner-all-courses") {
                    Image("banner-all-courses")
                        .resizable()
                        .scaledToFit()
                } else {
                    Color(.secondarySystemBackground)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(maxWidth: .infinity)   // ← та же ширина, что у левой части
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal, 16)
    }
}


// MARK: - Row cards (новые курсы)
struct CourseRowCard: View {
    let course: CourseItem
    var rowHeight: CGFloat = 110

    var body: some View {
        HStack(spacing: 12) {
            // 50% — изображение
            Group {
                if let n = course.imageAsset, ImageAsset.exists(n) {
                    Image(n).resizable().scaledToFill()
                } else {
                    Color(.secondarySystemBackground)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(maxWidth: .infinity)       // ← половина ширины
            .frame(height: rowHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // 50% — текст
            VStack(alignment: .leading, spacing: 6) {
                Text(course.title)
                    .font(.headline)
                    .lineLimit(2)

                Text("#\(course.tag)")
                    .font(.footnote)
                    .foregroundStyle(Color.accentColor)

                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text("Уроков : \(course.lessons)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // ← вторая половина
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }
}


// MARK: - Tile cards (популярные)

private struct CourseTileCard: View {
    let course: CourseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if let n = course.imageAsset, ImageAsset.exists(n) {
                    Image(n).resizable().scaledToFit()
                } else {
                    Color(.secondarySystemBackground)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(course.title).font(.headline)
            Text("#\(course.tag)").font(.caption).foregroundStyle(Color.accentColor)
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Уроков : \(course.lessons)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(course.tileTint ?? Color(.systemBackground))
        )
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }
}

// MARK: - Helpers

private struct SectionHeaderRow: View {
    var title: String
    var actionTitle: String
    var action: () -> Void
    var body: some View {
        HStack {
            Text(title).font(.title3)
            Spacer()
            Button(actionTitle, action: action)
                .font(.callout)
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

private struct TagPill: View {
    var text: String
    var isSelected: Bool = false
    var body: some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            )
    }
}

// MARK: - Data

struct CourseItem: Identifiable {
    let id = UUID()
    let title: String
    let tag: String
    let lessons: Int
    let imageAsset: String?
    let tileTint: Color?

    static let newCourses: [CourseItem] = [
        .init(title: "Курсы English",
              tag: "Английский",
              lessons: 10,
              imageAsset: "course-english",   // ← 1-я картинка
              tileTint: nil),
        .init(title: "Курсы “Лидерства”",
              tag: "Менеджмент",
              lessons: 15,
              imageAsset: "course-leadership", // ← 2-я картинка
              tileTint: nil)
    ]

    static let popularCourses: [CourseItem] = [
        .init(title: "Курсы “Лидерства”",
              tag: "Менеджмент",
              lessons: 15,
              imageAsset: "course-leadership",
              tileTint: Color(.secondarySystemBackground)),
        .init(title: "Курсы English",
              tag: "Английский",
              lessons: 10,
              imageAsset: "course-english",
              tileTint: Color.yellow.opacity(0.15))
    ]
}

// MARK: - Модель фильтра
struct FilterSettings: Equatable {
    enum Price: String, CaseIterable { case any, paid, free }
    var category: String? = nil
    var price: Price = .any
    var minRating: Int = 4
    mutating func reset() { self = FilterSettings() }
}

struct FilterSheet: View {
    @Binding var filters: FilterSettings
    var onApply: () -> Void

    @Environment(\.dismiss) private var dismiss

    // Черновик — локальная копия фильтров
    @State private var draft: FilterSettings

    init(filters: Binding<FilterSettings>, onApply: @escaping () -> Void) {
        _filters = filters
        self.onApply = onApply
        _draft = State(initialValue: filters.wrappedValue)
    }

    private let categories = ["Маркетинг","Excel","Тайм менеджмент","Дизайн","SMM"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Категория") {
                    Picker("Категория",
                           selection: Binding<String?>(
                               get: { draft.category },
                               set: { draft.category = $0 }
                           )
                    ) {
                        Text("Любая").tag(String?.none)
                        ForEach(categories, id: \.self) { c in
                            Text(c).tag(String?.some(c))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Оплата") {
                    Picker("Оплата", selection: $draft.price) {
                        Text("Любая").tag(FilterSettings.Price.any)
                        Text("Платный").tag(FilterSettings.Price.paid)
                        Text("Бесплатный").tag(FilterSettings.Price.free)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Рейтинг курса") {
                    HStack {
                        StarRow(rating: $draft.minRating)
                        Spacer()
                        Text("\(draft.minRating)+").foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Сбросить") { draft.reset() }
                }
                // Кнопка "Готово" применяет только черновик
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        filters = draft
                        onApply()
                        dismiss()
                    }
                }
            }
        }
        // свайпом вниз можно закрыть — изменения НЕ применятся, т.к. в filters мы не записали
    }
}


// Звёздочки рейтинга
private struct StarRow: View {
    @Binding var rating: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .imageScale(.large)
                    .foregroundStyle(.yellow)
                    .onTapGesture { rating = i }
            }
        }
    }
}


// MARK: - Вспомогательные компоненты
private struct RadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "smallcircle.filled.circle" : "circle")
                    .font(.title3)
                Text(title).font(.callout)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Color.accentColor : .primary)
    }
}

struct SearchResultsList: View {
    let query: String
    let results: [CourseItem]
    let clear: () -> Void
    var showClear: Bool = true     // ← новый параметр

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Найдено: \(results.count)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                if showClear {
                    Button("Очистить", action: clear)
                        .font(.callout)
                }
            }

            if results.isEmpty {
                EmptyResultsView()
            } else {
                ForEach(results) { course in
                    NavigationLink { CourseDetailScreen(course: course) } label: {
                        SearchResultRow(course: course, query: query)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}


private struct EmptyResultsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
                .foregroundStyle(.secondary)
            Text("Ничего не найдено")
                .font(.headline)
            Text("Попробуйте изменить запрос или фильтры.")
                .font(.callout).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }
}

private struct SearchResultRow: View {
    let course: CourseItem
    let query: String
    var rowHeight: CGFloat = 88

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let n = course.imageAsset, ImageAsset.exists(n) {
                    Image(n).resizable().scaledToFill()
                } else {
                    Color(.secondarySystemBackground)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(width: rowHeight * 1.2, height: rowHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                // Подсвечиваем совпадение в заголовке
                Text(highlight(course.title, with: query))
                    .font(.headline)
                    .lineLimit(2)

                Text("#\(course.tag)")
                    .font(.footnote)
                    .foregroundStyle(Color.accentColor)

                Text("Уроков : \(course.lessons)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }

    private func highlight(_ text: String, with query: String) -> AttributedString {
        var a = AttributedString(text)
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, let r = a.range(of: q, options: [.caseInsensitive, .diacriticInsensitive]) else {
            return a
        }
        a[r].foregroundColor = .accentColor
        a[r].font = .headline.bold()
        return a
    }
}


extension String {
    var normalized: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
