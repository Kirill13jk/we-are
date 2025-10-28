import Foundation

struct AppNotification: Identifiable, Hashable, Codable {
    let id: UUID
    var companyName: String
    var companyLogoAsset: String?
    var date: Date
    var title: String
    var preview: String
    var fullText: String
    var imageAsset: String?
    var isRead: Bool
    var isExpanded: Bool

    init(
        id: UUID = .init(),
        companyName: String,
        companyLogoAsset: String? = nil,
        date: Date = .init(),
        title: String,
        preview: String,
        fullText: String? = nil,
        imageAsset: String? = nil,
        isRead: Bool = false,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.companyName = companyName
        self.companyLogoAsset = companyLogoAsset
        self.date = date
        self.title = title
        self.preview = preview
        self.fullText = fullText ?? preview
        self.imageAsset = imageAsset
        self.isRead = isRead
        self.isExpanded = isExpanded
    }
}

extension AppNotification {
    static let demo: [AppNotification] = [
        .init(companyName: "Yaponamama", companyLogoAsset: "yapo-logo",
              date: Date().addingTimeInterval(-7200),
              title: "Уведомление",
              preview: "Краткое описание новости. Нажмите, чтобы развернуть.",
              fullText: "Полный текст…"),
        .init(companyName: "Bellstore", companyLogoAsset: "bell-logo",
              date: Date().addingTimeInterval(-93600),
              title: "Новости магазина",
              preview: "Поступление новой косметики…",
              fullText: "Большая поставка…", imageAsset: "post-1", isRead: true),
        .init(companyName: "MUNA", companyLogoAsset: "muna-logo",
              date: Date().addingTimeInterval(-172800),
              title: "Обновление приложения",
              preview: "Вышла новая версия. Что нового?",
              fullText: "Исправлены ошибки…")
    ]
}
