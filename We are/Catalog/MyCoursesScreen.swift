import SwiftUI

struct MyCoursesScreen: View {
    enum Tab { case current, completed }

    @State private var tab: Tab
    @State private var showSwitcher = false
    @State private var pushCatalog = false

    init(initialTab: Tab = .current) { _tab = State(initialValue: initialTab) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("", selection: $tab) {
                    Text("Текущие").tag(Tab.current)
                    Text("Завершенные").tag(Tab.completed)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if tab == .current {
                    VStack(spacing: 12) {
                        CurrentCourseCard(
                            title: "Курсы English",
                            tag: "Маркетинг",
                            lessons: 10,
                            progress: 0.87,
                            image: "mycourse-current-1"   // ← добавишь ассет
                        )
                        CurrentCourseCard(
                            title: "Курсы English",
                            tag: "Маркетинг",
                            lessons: 10,
                            progress: 0.87,
                            image: "mycourse-current-1"   // ← добавишь ассет
                        )
                    }
                    .padding(.horizontal, 16)
                } else {
                    VStack(spacing: 12) {
                        CompletedCourseCard(
                            title: "Менеджмент",
                            tag: "Экономика",
                            totalLessons: 35,
                            finalScoreText: "Итоговый балл 95",
                            image: "mycourse-completed"    // ← добавишь ассет
                        )
                    }
                    .padding(.horizontal, 16)
                }

                Spacer(minLength: 8)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("Мои курсы")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button { showSwitcher = true } label: {
                    HStack(spacing: 6) {
                        Text("Мои курсы").font(.headline)     // ← правильный заголовок
                        Image(systemName: "chevron.down")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
        }
        // Стандартный Action Sheet
        .confirmationDialog("", isPresented: $showSwitcher, titleVisibility: .hidden) {
            Button("Каталог курсов") { pushCatalog = true }   // ← здесь был pushMyCourses
            Button("Мои курсы")      { /* остаёмся тут */ }
            Button("Отменить", role: .cancel) { }
        }
        // Переход в каталог без deprecated API
        .navigationDestination(isPresented: $pushCatalog) {
            CatalogScreen()
        }
    }
}

// MARK: - Карточки

struct CurrentCourseCard: View {
    var title: String
    var tag: String
    var lessons: Int
    var progress: CGFloat
    var image: String

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if ImageAsset.exists(image) {
                    Image(image).resizable().scaledToFit()
                } else {
                    Color(.secondarySystemBackground)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(width: 110, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text("#\(tag)").font(.footnote).foregroundStyle(Color.accentColor)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.footnote).foregroundStyle(.secondary).lineLimit(2)
                HStack {
                    Text("Уроков : \(lessons)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100)) %")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                ProgressView(value: progress)
                    .tint(Color.accentColor)
            }

            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }
}

private struct CompletedCourseCard: View {
    var title: String
    var tag: String
    var totalLessons: Int
    var finalScoreText: String
    var image: String

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if ImageAsset.exists(image) {
                    Image(image).resizable().scaledToFit()
                } else {
                    Color(.secondarySystemBackground)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(width: 110, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text("#\(tag)").font(.footnote).foregroundStyle(Color.accentColor)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.footnote).foregroundStyle(.secondary).lineLimit(2)
                Text("Уроков : \(totalLessons)")
                    .font(.footnote).foregroundStyle(.secondary)
                Text(finalScoreText)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.green)
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }
}
