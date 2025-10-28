// CatalogScreen.swift
import SwiftUI

struct CatalogScreen: View {
    @State private var search = ""
    @State private var selectedTag = "Маркетинг"
    
    private let sideInset: CGFloat = 16
    
    @State private var showSwitcher = false
    @State private var pushMyCourses = false

    @State private var pushNewList = false
    @State private var pushPopularList = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Поиск + фильтры
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                            TextField("Поиск курсов", text: $search)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))

                        Button { /* открыть фильтры */ } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

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
                                ForEach(["Маркетинг","Excel","Тайм менеджмент","Дизайн","SMM"], id: \.self) { tag in
                                    TagPill(text: tag, isSelected: tag == selectedTag)
                                        .onTapGesture { selectedTag = tag }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Новые курсы — список
                    SectionHeaderRow(title: "Новые курсы", actionTitle: "Все") {
                        pushNewList = true                      // ← переход на экран «Новые курсы»
                    }
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
                    .padding(.horizontal, sideInset)

                    // Популярные курсы — 2 колонки
                    SectionHeaderRow(title: "Популярные курсы", actionTitle: "Все") {
                        pushPopularList = true                  // ← переход на экран «Популярные курсы»
                    }
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(CourseItem.popularCourses) { course in
                            NavigationLink {
                                CourseDetailScreen(course: course)
                            } label: {
                                CourseTileCard(course: course)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, sideInset)

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
        }
    }
}

// Экран «Новые курсы» (2-й скрин)
struct NewCoursesListScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(CourseItem.newCourses) { course in
                    CourseRowCard(course: course)
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

// Экран «Популярные курсы» (3-й скрин)
struct PopularCoursesListScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // для списка популярного возьмём «горизонтальные» карточки с прогрессом
                CurrentCourseCard(title: "Курсы English", tag: "Маркетинг", lessons: 10, progress: 0.87, image: "mycourse-current-1")
                CurrentCourseCard(title: "Курсы “СММ”",   tag: "Маркетинг", lessons: 15, progress: 0.45, image: "mycourse-current-1")
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
              tag: "Маркетинг",
              lessons: 10,
              imageAsset: "course-english",   // ← 1-я картинка
              tileTint: nil),
        .init(title: "Курсы “Лидерства”",
              tag: "Маркетинг",
              lessons: 15,
              imageAsset: "course-leadership", // ← 2-я картинка
              tileTint: nil)
    ]

    static let popularCourses: [CourseItem] = [
        .init(title: "Курсы “Лидерства”",
              tag: "Маркетинг",
              lessons: 15,
              imageAsset: "course-leadership",
              tileTint: Color(.secondarySystemBackground)),
        .init(title: "Курсы English",
              tag: "Маркетинг",
              lessons: 10,
              imageAsset: "course-english",
              tileTint: Color.yellow.opacity(0.15))
    ]
}

