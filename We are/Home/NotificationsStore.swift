// NotificationsStore.swift
import SwiftUI
import Combine   // ← обязательно!

@MainActor
final class NotificationsStore: ObservableObject {
    @AppStorage("notifications.v1") private var saved: Data = .init()

    @Published var items: [AppNotification] = [] {
        didSet { persist() }
    }

    init() {
        if let arr = try? JSONDecoder().decode([AppNotification].self, from: saved),
           !arr.isEmpty {
            items = arr
        } else {
            items = AppNotification.demo
            persist()
        }
    }

    var unreadCount: Int { items.filter { !$0.isRead }.count }

    func add(_ n: AppNotification) { items.insert(n, at: 0) }
    func remove(_ id: UUID) { items.removeAll { $0.id == id } }

    func markAsRead(_ id: UUID, _ read: Bool = true) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].isRead = read
    }

    func markAllAsRead() {
        for i in items.indices { items[i].isRead = true }
    }

    func toggleExpanded(_ id: UUID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].isExpanded.toggle()
    }

    private func persist() {
        saved = (try? JSONEncoder().encode(items)) ?? .init()
    }
}
