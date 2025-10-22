import SwiftUI

struct SkillsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var skills: [String]

    @State private var query = ""
    @FocusState private var focusSearch: Bool

    // Банк подсказок (можете расширить / подгружать с сервера)
    private let catalog: [String] = [
        "Общение", "Общение с клиентами", "Деловое общение",
        "Навыки ведения отчетности", "Опыт консультирования покупателей",
        "Умение работать с кассовым аппаратом", "Продажи", "Мерчандайзинг",
        "Работа с возражениями", "Кассовая дисциплина", "Инвентаризация"
    ]

    private var suggestions: [String] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return catalog.filter { !skills.contains($0) } }
        return catalog
            .filter { $0.localizedCaseInsensitiveContains(q) }
            .filter { !skills.contains($0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Поисковая строка
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Название навыка", text: $query)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusSearch)
                            .onSubmit { addFromQuery() }

                        if !query.isEmpty {
                            Button {
                                query = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                    )

                    // Список выбранных навыков (как на 3-м скрине)
                    if !skills.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(skills, id: \.self) { skill in
                                HStack(alignment: .firstTextBaseline) {
                                    Text(skill)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Button {
                                        remove(skill)
                                    } label: {
                                        Image(systemName: "xmark.circle")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                    }
                                    .accessibilityLabel("Удалить «\(skill)»")
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.separator), lineWidth: 0.5)
                                        )
                                )
                            }
                        }
                    }

                    // Подсказки (как на 2-м скрине)
                    if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    add(s)
                                } label: {
                                    Text(s)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, skills.isEmpty ? 0 : 8)
                    }

                    Spacer(minLength: 12)
                }
                .padding(16)
            }
            .navigationTitle("Ключевые навыки")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    addFromQuery()
                    dismiss()
                } label: {
                    Text("Сохранить")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .foregroundStyle(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
            }
            .onAppear { focusSearch = true }
        }
    }

    // MARK: - Helpers
    private func add(_ s: String) {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty, !skills.contains(where: { $0.caseInsensitiveCompare(v) == .orderedSame }) else { return }
        skills.append(v)
        query = ""
    }

    private func addFromQuery() { add(query) }

    private func remove(_ s: String) {
        skills.removeAll { $0.caseInsensitiveCompare(s) == .orderedSame }
    }
}
