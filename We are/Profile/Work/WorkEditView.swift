// WorkEditView.swift
import SwiftUI

struct WorkEditView: View {
    @Environment(\.dismiss) private var dismiss

    // Редактируем копию записи
    @State private var draft: Workplace
    @State private var isCurrent: Bool

    let onFinish: (Workplace, Bool) -> Void   // (updated, isDelete)

    init(work: Workplace, onFinish: @escaping (Workplace, Bool) -> Void) {
        _draft = State(initialValue: work)
        _isCurrent = State(initialValue: work.end == nil)
        self.onFinish = onFinish
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Group {
                        Text("Организация").font(.headline)

                        TextField("Название компании", text: $draft.company)
                            .modifier(WorkFieldBox())

                        TextField("Должность", text: $draft.position)
                            .modifier(WorkFieldBox())
                    }

                    Group {
                        Text("Начало работы").font(.headline)

                        DatePicker("",
                                   selection: $draft.start,
                                   displayedComponents: .date)
                            .labelsHidden()
                            .modifier(WorkFieldBox())
                    }

                    Group {
                        Text("Окончание").font(.headline)

                        DatePicker("",
                                   selection: endBinding,
                                   displayedComponents: .date)
                            .labelsHidden()
                            .modifier(WorkFieldBox())
                            .disabled(isCurrent)
                            .opacity(isCurrent ? 0.5 : 1)

                        Toggle("По настоящее время", isOn: $isCurrent)
                            .onChange(of: isCurrent) { _, v in
                                if v { draft.end = nil }
                                else if draft.end == nil { draft.end = Date() }
                            }
                    }

                    if existingRecord {
                        Button(role: .destructive) {
                            onFinish(draft, true)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle")
                                Text("Удалить")
                            }
                        }
                        .padding(.top, 6)
                    }

                    Spacer(minLength: 8)
                }
                .padding(16)
            }
            // Заголовок: показываем должность, если она не пустая
            .navigationTitle(draft.position.isEmpty ? "Место работы" : draft.position)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    onFinish(draft, false)
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
        }
    }

    // Binding для опциональной даты окончания
    private var endBinding: Binding<Date> {
        Binding<Date>(
            get: { draft.end ?? Date() },
            set: { draft.end = $0 }
        )
    }

    // Понимаем, что это существующая запись (показывать "Удалить")
    private var existingRecord: Bool {
        !draft.company.isEmpty || !draft.position.isEmpty
    }
}

// Локальный модификатор под поле (уникальное имя — не конфликтует с другими файлам)
private struct WorkFieldBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
