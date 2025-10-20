// WorkEditView.swift
import SwiftUI

struct WorkEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State var work: Workplace
    var onSave: (Workplace, Bool) -> Void   // (work, isDelete)

    @State private var isCurrent: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Group {
                        Text("Организация").font(.headline)
                        TextField("Название компании", text: $work.company)
                            .modifier(FilledField())

                        TextField("Должность", text: $work.position)
                            .modifier(FilledField())
                    }

                    Group {
                        Text("Начало работы").font(.headline)
                        DatePicker("", selection: $work.start, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .modifier(FilledField())
                    }

                    Group {
                        Text("Окончание").font(.headline)
                        DatePicker("", selection: Binding<Date>(
                            get: { work.end ?? Date() },
                            set: { work.end = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .disabled(isCurrent)
                        .opacity(isCurrent ? 0.5 : 1)
                        .modifier(FilledField())

                        Toggle("По настоящее время", isOn: $isCurrent)
                            .onChange(of: isCurrent) { _, v in work.end = v ? nil : (work.end ?? Date()) }
                    }

                    // Удалить
                    if existingRecord {
                        Button(role: .destructive) {
                            onSave(work, true)
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
            .navigationTitle("Место работы")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    onSave(work, false)
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
            .onAppear { isCurrent = (work.end == nil) }
        }
    }

    private var existingRecord: Bool { work.company.isEmpty == false || work.position.isEmpty == false }
}
