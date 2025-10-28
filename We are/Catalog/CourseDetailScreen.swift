import SwiftUI

private enum CourseDetailTab { case about, modules, reviews }

struct CourseDetailScreen: View {
    let course: CourseItem

    @State private var tab: CourseDetailTab = .about
    @State private var showReviewSheet = false
    @State private var showThanks = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // HEADER как на макете (розовый фон + иллюстрация + play)
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemPink).opacity(0.18))
                        .frame(height: 180)
                        .overlay(
                            Group {
                                if let n = course.imageAsset, ImageAsset.exists(n) {
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

                    // кружок play → открываем старт урока
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
                Text("Курсы “\(course.title)”")
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
                    case .about: AboutTab()
                    case .modules: ModulesTab()
                    case .reviews:
                        ReviewsTab(openForm: { showReviewSheet = true })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // Форма отзыва — единственный sheet (не будет предупреждений)
        .sheet(isPresented: $showReviewSheet) {
            ReviewFormSheet(
                courseTitle: course.title,
                imageName: course.imageAsset,
                onSubmit: { _rating, _text in
                    // тут можешь сохранить отзыв в стор/сервер
                    showThanks = true
                }
            )
            .presentationDetents([.large])
        }
        // Поп-ап «Спасибо!»
        .overlay {
            if showThanks {
                ThanksOverlay { showThanks = false }
            }
        }
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loremLong)
                .foregroundStyle(.secondary)

            Divider().opacity(0.2)

            HStack(spacing: 10) {
                Image(systemName: "clock")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Примерное время прохождения курса")
                        .font(.subheadline)
                    Text("18 часов")
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
    private struct ModuleItem: Identifiable {
        let id = UUID()
        let idx: Int
        let title: String
        let subtitle: String
    }

    private let modules: [ModuleItem] = [
        .init(idx: 1, title: "Название урока", subtitle: "Lorem ipsum dolor sit amet"),
        .init(idx: 2, title: "Название урока", subtitle: "Lorem ipsum dolor sit amet"),
        .init(idx: 3, title: "Название урока", subtitle: "Lorem ipsum dolor sit amet"),
        .init(idx: 4, title: "Название урока", subtitle: "Lorem ipsum dolor sit amet")
    ]

    var body: some View {
        VStack(spacing: 18) {
            ForEach(modules) { m in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 88, height: 64)
                        .overlay {
                            if ImageAsset.exists("course-english") {
                                Image("course-english")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
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
    var openForm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // ленивый «дайджест» рейтинга (для вида)
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading) {
                    Text("5.0").font(.system(size: 36, weight: .bold))
                    StarsRow(rating: 4.0)
                        .padding(.top, 2)
                    Text("из 5").font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach((0..<5).reversed(), id: \.self) { _ in
                        Rectangle().fill(Color(.secondarySystemFill)).frame(width: 140, height: 8).clipShape(Capsule())
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

            Text("24 отзыва о курсе")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)

            // пара демо-карточек
            ReviewCard(name: "Виктор", text: "Lorem ipsum dolor sit amet, consectetur adipiscing…", date: "03.03.2022 / 10:30")
            ReviewCard(name: "Дарья", text: loremShort, date: "03.03.2022 / 10:30", expanded: true)
        }
    }

    private struct ReviewCard: View {
        var name: String
        var text: String
        var date: String
        var expanded: Bool = false
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

                Text(isExpanded || expanded ? text : String(text.prefix(120)) + "…")
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

// MARK: - Review form (sheet)

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
                    // Шапка
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

                    // Рейтинг
                    VStack(spacing: 14) {
                        Text("Поставьте оценку").foregroundStyle(.secondary)
                        StarsInput(rating: $rating)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(.separator), lineWidth: 0.5))

                    // Поле
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
