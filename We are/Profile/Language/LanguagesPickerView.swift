import SwiftUI

struct LanguagesPickerView: View {
    /// Уже сохранённые в профиле языки
    let existing: [LanguageSkill]
    /// Возврат объединённого массива (existing + выбранные/обновлённые)
    var onDone: (_ merged: [LanguageSkill]) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var search = ""

    /// Выбранные пары "код языка → уровень"
    @State private var picked: [String: ProficiencyLevel] = [:]

    /// Для выбора уровня
    @State private var activeCodeForLevel: String?
    @State private var showLevelDialog = false

    // MARK: - Filtered options
    private var options: [LanguageOption] {
        let src = LanguageOption.all
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.isEmpty ? src : src.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(options) { option in
                    HStack(spacing: 12) {
                        RadioCircle(isOn: picked[option.code] != nil)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.name)
                            if let level = picked[option.code] {
                                Text(level.title)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeCodeForLevel = option.code
                        showLevelDialog = true
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Добавление языка")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $search,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск"
            )

            // Кнопка «Сохранить» закреплена у низа
            .safeAreaInset(edge: .bottom) {
                Button(action: saveAndClose) {
                    Text("Сохранить")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .foregroundStyle(.white)
                        .background(picked.isEmpty ? Color.accentColor.opacity(0.4) : Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                }
                .disabled(picked.isEmpty)
                .background(.ultraThinMaterial)
            }
        }
        // При открытии подсветим всё, что уже есть в профиле
        .onAppear {
            picked = Dictionary(
                uniqueKeysWithValues: existing.map { ($0.language.code, $0.level) }
            )
        }
        // Выбор уровня — без второго .sheet
        .confirmationDialog("Уровень владения", isPresented: $showLevelDialog, titleVisibility: .visible) {
            // Не предлагаем .native — «Родной» задаётся дефолтом
            ForEach(ProficiencyLevel.allCases.filter { $0 != .native }, id: \.self) { level in
                Button(level.title) {
                    if let code = activeCodeForLevel {
                        picked[code] = level
                    }
                }
            }
            if let code = activeCodeForLevel, picked[code] != nil {
                Button("Убрать язык", role: .destructive) {
                    picked[code] = nil
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }

    // MARK: - Save
    private func saveAndClose() {
        // Собираем итог: обновляем уровни для выбранных и добавляем новые.
        var merged = existing

        for (code, level) in picked {
            guard let opt = LanguageOption.all.first(where: { $0.code == code }) else { continue }

            if let idx = merged.firstIndex(where: { $0.language.code == code }) {
                merged[idx].language = opt
                merged[idx].level = level
            } else {
                merged.append(LanguageSkill(language: opt, level: level))
            }
        }

        onDone(merged)
        dismiss()
    }
}

// MARK: - Small helper radio view (чтобы не было "Cannot find RadioCircle")
struct RadioCircle: View {
    var isOn: Bool
    var body: some View {
        ZStack {
            Circle().stroke(Color.accentColor, lineWidth: 3).frame(width: 26, height: 26)
            if isOn {
                Circle().fill(Color.accentColor).frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 6)
    }
}
