// WorkExperienceListView.swift
import SwiftUI

struct WorkExperienceListView: View {
    @EnvironmentObject private var profile: ProfileModel
    @Environment(\.dismiss) private var dismiss
    @State private var editing: Workplace? = nil
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    if profile.workplaces.isEmpty {
                        // Пустой контейнер
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Пока нет опыта работы").font(.headline)
                                Text("Нажмите «Добавить место работы», чтобы заполнить раздел.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    } else {
                        // Карточки
                        ForEach(profile.workplaces) { work in
                            Card {
                                WorkplaceCard(work: work)
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // Кнопка «Добавить место работы»
                    Button {
                        editing = Workplace()     // пустая запись
                        showEditor = true
                    } label: {
                        Label("Добавить место работы", systemImage: "plus.circle")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .padding(.vertical, 12)
                // запас под нижнюю фикс-кнопку
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Опыт работы")
            .navigationBarTitleDisplayMode(.inline)

            // Фиксированная нижняя кнопка по макету
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button {
                        profile.persist()
                        dismiss()
                    } label: {
                        Text("Сохранить")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .foregroundStyle(.white)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                // светлая подложка как на скрине
                .background(.ultraThinMaterial)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) // чтобы кнопка не прыгала при клавиатуре
            .sheet(isPresented: $showEditor, onDismiss: { profile.persist() }) {
                if let editing {
                    WorkEditView(work: editing) { updated, isDelete in
                        if isDelete {
                            profile.workplaces.removeAll { $0.id == updated.id }
                        } else if let idx = profile.workplaces.firstIndex(where: { $0.id == updated.id }) {
                            profile.workplaces[idx] = updated
                        } else {
                            profile.workplaces.append(updated)
                        }
                    }
                }
            }
        }
    }
}


// Карточка под макет
struct WorkplaceCard: View {
    let work: Workplace

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // верхняя строка: должность + галочка, справа рейтинг
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    Text(work.position.isEmpty ? "—" : work.position)
                        .font(.headline)
                    if work.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Spacer()
                if let r = work.rating {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", r))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }

            // компания
            Text("Компания “\(work.company.isEmpty ? "—" : work.company)”")
                .foregroundStyle(.secondary)

            // период
            Text(WorkFmt.period(work.start, work.end))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .overlay(alignment: .topTrailing) {
            // иконка «скрепка» в правом-верхнем углу
            Image(systemName: "paperclip.circle")
                .font(.title3)
                .padding(10)
        }
    }
}
