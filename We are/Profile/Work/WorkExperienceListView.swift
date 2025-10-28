// WorkExperienceListView.swift
import SwiftUI

struct WorkExperienceListView: View {
    @EnvironmentObject private var profile: ProfileModel
    @Environment(\.dismiss) private var dismiss

    // было: editing + showEditor
    @State private var editing: Workplace?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    if profile.workplaces.isEmpty {
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Пока нет опыта работы").font(.headline)
                                Text("Нажмите «Добавить место работы», чтобы заполнить раздел.")
                                    .font(.callout).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ForEach(profile.workplaces) { work in
                            // вся карточка кликабельна — открывает редактор
                            Button {
                                editing = work
                            } label: {
                                Card { WorkplaceCard(work: work) }
                                    .padding(.horizontal, 16)
                                    .overlay(alignment: .trailing) {
                                        Image(systemName: "paperclip.circle")
                                            .font(.title3).padding(12)
                                            .foregroundStyle(.secondary)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // «Добавить место работы»
                    Button {
                        editing = Workplace()   // пустая запись
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle")
                            Text("Добавить место работы")
                        }
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.top, 8)
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Опыт работы")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
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
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
            }

            // ВАЖНО: показываем шит только когда item != nil
            .sheet(item: $editing, onDismiss: { profile.persist() }) { item in
                WorkEditView(work: item) { updated, isDelete in
                    if isDelete {
                        profile.workplaces.removeAll { $0.id == updated.id }
                    } else if let idx = profile.workplaces.firstIndex(where: { $0.id == updated.id }) {
                        profile.workplaces[idx] = updated
                    } else {
                        profile.workplaces.append(updated)
                    }
                    editing = nil  // закрыть шит вручную после сохранения/удаления
                }
            }
        }
    }
}

private struct WorkRow: View {
    let work: Workplace
    var edit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(work.position.isEmpty ? "—" : work.position)
                    .font(.headline)
                if work.verified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.accentColor)
                }
                Spacer()
                if let r = work.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text(String(format: "%.1f", r)).foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }

            Text("Компания “\(work.company)”")
                .foregroundStyle(.secondary)

            Text(WorkFmt.period(work.start, work.end))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .appCard()
        .contentShape(Rectangle())    // весь контейнер тапаемый
        .onTapGesture(perform: edit)
        .overlay(alignment: .bottomTrailing) {
            Button(action: edit) {
                Image(systemName: "paperclip.circle")
                    .font(.title3)
                    .padding(8)
            }
        }
    }
}

// Универсальный стиль карточки (без конфликта имён с вашим Card)
private struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}
private struct AccessoryChip: View {
    var icon: String = "chevron.right"

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            )
    }
}

private extension View {
    func appCard() -> some View { modifier(AppCardModifier()) }
}
struct WorkplaceCard: View {
    let work: Workplace

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Заголовок: должность, верификация, рейтинг (★ + число) справа
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(work.position.isEmpty ? "Должность" : work.position)
                    .font(.headline)

                if work.verified {                     // <- у модели флаг называется verified
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.accentColor)
                }

                Spacer()

                if let r = work.rating {               // <- показываем число
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", r))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text("Компания “\(work.company)”")
                .font(.subheadline)

            Text(WorkFmt.period(work.start, work.end))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}


// Общая кликабельная карточка со стрелкой, одинаковый padding/corner/shadow
struct TappableCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        Card { content }
            .overlay(alignment: .trailing) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .padding(12)
            }
            .padding(.horizontal, 16)   // единый отступ
    }
}
