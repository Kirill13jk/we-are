import SwiftUI

// Карточка уведомления
struct NotificationCard: View {
    let item: AppNotification
    var onToggleExpanded: () -> Void
    var onOpen: () -> Void

    private var dateText: String {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "dd.MM.yyyy / HH:mm"
        return df.string(from: item.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Верхняя строка
            HStack(alignment: .center, spacing: 12) {
                // Аватар/лого
                Group {
                    if let n = item.companyLogoAsset, ImageAsset.exists(n) {
                        Image(n).resizable().scaledToFill()
                    } else {
                        Image(systemName: "building.2.fill")
                            .resizable().scaledToFit()
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .clipShape(Circle())

                Text(item.companyName)
                    .font(.headline)

                Spacer()
                Text(dateText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // Картинка (опционально)
            if let img = item.imageAsset, ImageAsset.exists(img) {
                Image(img)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Заголовок и текст
            Text(item.title)
                .font(.title3)

            Text(item.isExpanded ? item.fullText : item.preview)
                .foregroundStyle(.secondary)

            HStack {
                Button(action: onToggleExpanded) {
                    Image(systemName: item.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }
                Spacer()
                Button("Открыть", action: onOpen)
                    .font(.headline)
                    .tint(.accentColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .overlay(alignment: .leading) {
            if !item.isRead {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(width: 4)
                    .padding(.vertical, 8)
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

// Экран уведомлений
struct NotificationsScreen: View {
    @EnvironmentObject var notifications: NotificationsStore

    var body: some View {
        List {
            ForEach(notifications.items) { item in
                NotificationCard(
                    item: item,
                    onToggleExpanded: { notifications.toggleExpanded(item.id) },
                    onOpen: { notifications.markAsRead(item.id) }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.vertical, 4)
            }
            .onDelete { idx in
                idx.forEach { i in notifications.remove(notifications.items[i].id) }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Уведомления")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if notifications.unreadCount > 0 {
                    Button("Прочитать всё") { notifications.markAllAsRead() }
                }
            }
        }
    }
}
