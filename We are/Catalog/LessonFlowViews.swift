import SwiftUI

// MARK: - 1) Старт урока (экран «1 Модуль / Урок-1»)

struct LessonStartView: View {
    var courseTitle: String

    var body: some View {
        VStack(spacing: 20) {
            Text("1 Модуль")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Урок - 1")
                .font(.title2.weight(.semibold))

            // ИЛЛЮСТРАЦИЯ — добавь ассет с таким именем
            Image("lesson-start-illustration")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .padding(.horizontal, 24)

            Text("Учись вместе с нами\nи прокачивай свои скиллы!")
                .multilineTextAlignment(.center)
                .font(.headline)
                .padding(.top, 8)

            NavigationLink {
                LessonVideoView(courseTitle: courseTitle)
            } label: {
                Text("Начать!")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(16)
        .navigationTitle("1 Модуль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 2) Урок (видео + аннотация)

struct LessonVideoView: View {
    var courseTitle: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Past Simple Tense")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)

                // Плейсхолдер «видео»
                ZStack(alignment: .bottomLeading) {
                    Image("lesson-video-thumb")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // имитация прогресса/контролов (декор)
                    Rectangle().fill(.ultraThinMaterial)
                        .frame(height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            HStack(spacing: 16) {
                                Image(systemName: "play.fill")
                                Text("1:26 / 8:00")
                                Spacer()
                                Text("1x").font(.callout.weight(.semibold))
                                Image(systemName: "rectangle.inset.filled.badge.record") // «full screen» иконка
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                        , alignment: .leading)
                        .padding(6)
                }

                Text("""
Сегодня мы рассмотрим последнее время, относящееся к группе Simple в английской грамматике — **Past Simple Tense**. Как образуется утвердительная форма Past Simple?
""")
                .font(.body)
                .foregroundStyle(.primary)

                NavigationLink {
                    TestIntroView(courseTitle: courseTitle)
                } label: {
                    Text("Пройти тест")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        .navigationTitle("УРОК 1")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 3) Превью теста

struct TestIntroView: View {
    var courseTitle: String

    var body: some View {
        VStack(spacing: 20) {
            Text("1 Модуль")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text("Урок - 1: Тест")
                .font(.title2.weight(.semibold))

            Image("test-intro-illustration")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .padding(.horizontal, 24)

            Text("Пройдите тест и проверьте насколько\nвы хорошо изучили материал")
                .multilineTextAlignment(.center)
                .font(.headline)

            NavigationLink {
                TestRunnerView(
                    courseTitle: courseTitle,
                    questions: QuizQuestion.demo10
                )
            } label: {
                Text("Начать тест!")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(16)
        .navigationTitle("1 Модуль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 4–5) Прохождение теста (10 вопросов)

struct TestRunnerView: View {
    var courseTitle: String
    let questions: [QuizQuestion]

    @State private var index = 0
    @State private var answers: [Int?]

    init(courseTitle: String, questions: [QuizQuestion]) {
        self.courseTitle = courseTitle
        self.questions = questions
        _answers = State(initialValue: Array(repeating: nil, count: questions.count))
    }

    var body: some View {
        let q = questions[index]

        VStack(alignment: .leading, spacing: 16) {
            // Вопрос
            Text("\(index + 1). \(q.prompt)")
                .font(.title3.weight(.semibold))

            if let text = q.context {
                Text(text).foregroundStyle(.secondary)
            }

            // Варианты
            ForEach(q.options.indices, id: \.self) { i in
                Button {
                    answers[index] = i
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(answers[index] == i ? Color.accentColor : Color(.separator), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(answers[index] == i ? Color.accentColor : Color(.systemBackground))
                                )
                            HStack {
                                Image(systemName: answers[index] == i ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(answers[index] == i ? .white : Color.accentColor)
                                Text(q.options[i])
                                    .foregroundStyle(answers[index] == i ? .white : .primary)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 24)

            // Пейджер
            HStack {
                Button {
                    if index > 0 { index -= 1 }
                } label: {
                    Image(systemName: "chevron.left").font(.title3)
                }
                .disabled(index == 0)

                Spacer()
                Text("\(index + 1) / \(questions.count)").foregroundStyle(.secondary)
                Spacer()

                Button {
                    if index < questions.count - 1 { index += 1 }
                } label: {
                    Image(systemName: "chevron.right").font(.title3)
                }
                .disabled(index == questions.count - 1)
            }
            .padding(.bottom, 8)

            // Завершить на последнем
            NavigationLink {
                TestCongratsView(courseTitle: courseTitle)
            } label: {
                Text("Завершить тест")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(index == questions.count - 1 ? Color.accentColor : Color(.systemGray3))
                    )
            }
            .disabled(index != questions.count - 1)
        }
        .padding(16)
        .navigationTitle("Тест")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 6) Экран «Поздравляем!»
struct TestCongratsView: View {
    var courseTitle: String
    @State private var goToMyCourses = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Поздравляем!")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.accentColor)

            Text("1 Модуль / 1 Урок")
                .font(.title3)

            Image("lesson-congrats-illustration")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .padding(.horizontal, 24)

            Text("Вы завершили обучение 1 модуля\nтак держать!")
                .multilineTextAlignment(.center)
                .font(.headline)

            Button("Завершить") { goToMyCourses = true }
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        // 👇 Правильный модификатор, а не через .background
        .navigationDestination(isPresented: $goToMyCourses) {
            MyCoursesScreen(initialTab: .completed)
        }
    }
}


// MARK: - Вопросы теста (модель)

struct QuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let context: String?
    let options: [String]
    let correctIndex: Int

    static let demo10: [QuizQuestion] = [
        .init(prompt: "Choose the word or phrase that best completes each sentence.",
              context: "She arrived at 8 p.m., opened the door and shouted “ Good _____ ! “",
              options: ["morning", "evening", "night", "bye"], correctIndex: 1),
        .init(prompt: "Past Simple of the verb 'go' is…",
              context: nil,
              options: ["goed", "went", "goes", "gone"], correctIndex: 1),
        .init(prompt: "We ____ to the cinema yesterday.",
              context: nil,
              options: ["go", "goes", "went", "gone"], correctIndex: 2),
        .init(prompt: "He ____ at home last Sunday.",
              context: nil,
              options: ["stays", "stayed", "stay", "was stay"], correctIndex: 1),
        .init(prompt: "They ____ tennis last week.",
              context: nil,
              options: ["play", "played", "plays", "playing"], correctIndex: 1),
        .init(prompt: "I ____ dinner at 7 p.m.",
              context: nil,
              options: ["have", "had", "has", "having"], correctIndex: 1),
        .init(prompt: "She ____ a letter yesterday.",
              context: nil,
              options: ["write", "wrote", "written", "writes"], correctIndex: 1),
        .init(prompt: "We ____ happy to see you.",
              context: nil,
              options: ["was", "were", "are", "be"], correctIndex: 1),
        .init(prompt: "Tom ____ a new phone last month.",
              context: nil,
              options: ["buys", "buy", "bought", "buyed"], correctIndex: 2),
        .init(prompt: "The film ____ at 9 p.m.",
              context: nil,
              options: ["start", "started", "starts", "was start"], correctIndex: 1),
    ]
}
