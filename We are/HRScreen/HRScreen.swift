import SwiftUI
import UIKit

enum HRMode: String, CaseIterable { case candidates = "Кандидаты", vacancies = "Вакансии" }

struct HRScreen: View {
    @State private var mode: HRMode = .candidates
    @State private var search = ""
    @State private var showFilters = false
    @State private var savedIDs: Set<UUID> = []

    // демо-данные
    @State private var candidates = Candidate.demo
    @State private var vacancies  = Vacancy.demo
    
    private func toggleSaved(_ id: UUID) {
        savedIDs.formSymmetricDifference([id])   // если был — уберёт, если не было — добавит
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Segmented
                    Picker("", selection: $mode) {
                        ForEach(HRMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Поиск + фильтры
                    HStack(spacing: 10) {
                        SearchField(text: $search, placeholder: mode == .candidates ? "Поиск кандидатов" : "Поиск вакансий")
                        Button { showFilters = true } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)
                                .foregroundStyle(.accent)
                                .padding(8)
                        }
                        .accessibilityLabel("Фильтры")
                    }
                    .padding(.horizontal, 16)

                    // Список
                    VStack(spacing: 12) {
                        if mode == .candidates {
                            ForEach(filteredCandidates) { c in
                                CandidateCard(c: c,
                                              saved: savedIDs.contains(c.id),
                                              onSave: { toggleSaved(c.id) })
                                    .padding(.horizontal, 16)
                            }
                            if filteredCandidates.isEmpty { EmptyState(text: "Кандидаты не найдены") }
                        } else {
                            ForEach(filteredVacancies) { v in
                                VacancyCard(v: v,
                                            saved: savedIDs.contains(v.id),
                                            onSave: { toggleSaved(v.id) })
                                    .padding(.horizontal, 16)
                            }
                            if filteredVacancies.isEmpty { EmptyState(text: "Вакансии не найдены") }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("HR")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilters) {
                HRFilterSheet()
                    .presentationDetents([.height(360), .medium])
            }
        }
    }

    // MARK: Filtering
    private var filteredCandidates: [Candidate] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return candidates }
        return candidates.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.role.localizedCaseInsensitiveContains(q) ||
            $0.city.localizedCaseInsensitiveContains(q) ||
            $0.skills.joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }
    private var filteredVacancies: [Vacancy] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return vacancies }
        return vacancies.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.company.localizedCaseInsensitiveContains(q) ||
            $0.city.localizedCaseInsensitiveContains(q) ||
            $0.skills.joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }
}

// MARK: – Components

private struct CandidateCard: View {
    let c: Candidate
    var saved: Bool
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AvatarCircle(systemFallback: "person.fill")
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(c.name).font(.headline)
                    Text("\(c.role) • \(c.city)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                Spacer()
                SaveButton(saved: saved, tap: onSave)
            }

            HStack(spacing: 10) {
                Meta(icon: "briefcase.fill", text: "\(c.experience) лет опыта")
                Meta(icon: "ruler",         text: c.salary)
            }
            .font(.footnote)

            TagCloud(c.skills)

            HStack(spacing: 10) {
                Button("Связаться") { }    // TODO
                    .buttonStyle(.borderedProminent)
                Button("Подробнее") { }    // TODO
                    .buttonStyle(.bordered)
                Spacer()
            }
            .font(.subheadline)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

private struct VacancyCard: View {
    let v: Vacancy
    var saved: Bool
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AvatarCircle(systemFallback: "building.2.fill")
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(v.title).font(.headline)
                    Text("\(v.company) • \(v.city)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                Spacer()
                SaveButton(saved: saved, tap: onSave)
            }

            HStack(spacing: 10) {
                Meta(icon: "creditcard", text: v.salary)
                Meta(icon: "laptopcomputer", text: v.type.rawValue)
            }
            .font(.footnote)

            TagCloud(v.skills)

            HStack(spacing: 10) {
                Button("Откликнуться") { } // TODO
                    .buttonStyle(.borderedProminent)
                Button("Поделиться") { }   // TODO
                    .buttonStyle(.bordered)
                Spacer()
            }
            .font(.subheadline)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

private struct AvatarCircle: View {
    var systemFallback: String
    var body: some View {
        ZStack {
            Circle().fill(Color(.systemGray6))
            Image(systemName: systemFallback)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))
    }
}

private struct SaveButton: View {
    var saved: Bool
    var tap: () -> Void
    var body: some View {
        Button(action: tap) {
            Image(systemName: saved ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundStyle(saved ? .accent : .secondary)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(saved ? "В закладках" : "Сохранить")
    }
}

private struct Meta: View {
    var icon: String
    var text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(.secondary)
            Text(text)
        }
    }
}

// MARK: - Tag cloud with flow layout (iOS 16+)

private struct TagCloud: View {
    var tags: [String]
    init(_ tags: [String]) { self.tags = tags }

    var body: some View {
        FlowLayout(hSpacing: 8, vSpacing: 8) {
            ForEach(tags, id: \.self) { t in
                TagChip(text: t)
            }
        }
    }
}

private struct TagChip: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .lineLimit(2)                       // держим 1 строку, но позволяем перенестись на 2 при нужде
            .multilineTextAlignment(.center)
            .allowsTightening(true)
            .minimumScaleFactor(0.98)           // чуть ужимаем, чтобы не рвать слова зря
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
    }
}

/// Универсальный flow-layout: размещает сабвью в ряд и переносит на следующую строку.
/// Корректно учитывает доступную ширину и даёт `Text`у сузиться/перенестись.
private struct FlowLayout: Layout {
    var hSpacing: CGFloat = 8
    var vSpacing: CGFloat = 8

    init(hSpacing: CGFloat = 8, vSpacing: CGFloat = 8) {
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for sv in subviews {
            // сначала меряем естественный размер
            var size = sv.sizeThatFits(.unspecified)
            // ограничиваем ширину строкой, чтобы текст мог переноситься
            if size.width > maxWidth {
                size = sv.sizeThatFits(.init(width: maxWidth, height: nil))
            }

            if x + size.width > maxWidth {
                // перенос строки
                x = 0
                y += rowHeight + vSpacing
                rowHeight = 0
            }

            rowHeight = max(rowHeight, size.height)
            x += size.width + hSpacing
        }

        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for sv in subviews {
            // меряем с ограничением по доступной ширине (даём тексту возможность перенестись)
            var measured = sv.sizeThatFits(.unspecified)
            if measured.width > maxWidth {
                measured = sv.sizeThatFits(.init(width: maxWidth, height: nil))
            }

            if x + measured.width > bounds.maxX {
                // перенос на новую строку
                x = bounds.minX
                y += rowHeight + vSpacing
                rowHeight = 0
            }

            sv.place(
                at: CGPoint(x: x, y: y),
                proposal: .init(width: measured.width, height: measured.height)
            )

            x += measured.width + hSpacing
            rowHeight = max(rowHeight, measured.height)
        }
    }
}


private struct EmptyState: View {
    var text: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.fill.questionmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(text).foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
}

// MARK: – Filter sheet (визуально в духе iOS)
private struct HRFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remote = true
    @State private var fulltime = true
    @State private var minExp: Double = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("Формат работы") {
                    Toggle("Удалённо", isOn: $remote)
                    Toggle("Полная занятость", isOn: $fulltime)
                }
                Section("Минимальный опыт") {
                    HStack {
                        Slider(value: $minExp, in: 0...10, step: 1)
                        Text("\(Int(minExp)) г.").frame(width: 44, alignment: .trailing)
                    }
                }
            }
            .navigationTitle("Фильтры")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}

// MARK: – SearchField (как на главной)
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
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
    }
}

// MARK: – Demo models
struct Candidate: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var role: String
    var city: String
    var experience: Int
    var salary: String
    var skills: [String]

    static let demo: [Candidate] = [
        .init(name: "Алина Петрова", role: "Официант", city: "Ташкент", experience: 2, salary: "от 6 млн сум", skills: ["Обслуживание", "Клиентский сервис", "POS"]),
        .init(name: "Мурад Каримов", role: "Повар-сушист", city: "Самарканд", experience: 4, salary: "от 10 млн сум", skills: ["Суши/роллы", "HACCP", "Контроль качества"]),
        .init(name: "Елена Г.", role: "Хостес", city: "Ташкент", experience: 1, salary: "от 5 млн сум", skills: ["Коммуникации", "Английский A2", "Гостеприимство"])
    ]
}

enum EmploymentType: String { case full = "Полная", part = "Частичная", remote = "Удалённо" }

struct Vacancy: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var company: String
    var city: String
    var salary: String
    var type: EmploymentType
    var skills: [String]

    static let demo: [Vacancy] = [
        .init(title: "Повар-сушист", company: "Yaponamama", city: "Ташкент", salary: "10–14 млн сум", type: .full, skills: ["Суши/роллы", "Санитарные нормы", "Ночн. смены"]),
        .init(title: "Официант", company: "Bellstore Café", city: "Ташкент", salary: "6–8 млн сум + чаевые", type: .part, skills: ["POS", "Коммуникации"]),
        .init(title: "Хостес", company: "Jowi", city: "Самарканд", salary: "от 7 млн сум", type: .remote, skills: ["Онлайн-бронирование", "Английский"])
    ]
}
