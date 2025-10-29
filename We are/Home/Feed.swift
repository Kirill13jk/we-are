// MARK: - Feed model

import SwiftUI

struct Post: Identifiable, Hashable {
    let id = UUID()
    var company: Company
    var images: [String]          // имена ассетов
    var text: String
    var likes: Int
    var date: Date
    var liked: Bool = false
    var saved: Bool = false

    // демо-данные
    static let demo: [Post] = [
        .init(
            company: .demoProfile,
            images: ["yapo-1","yapo-2","yapo-3"],
            text: "Идеальная формула для тех, кто любит брать от жизни все! …",
            likes: 199,
            date: Calendar.current.date(byAdding: .hour, value: -2, to: .now) ?? .now
        ),
        .init(
            company: .init(name: "Bellstore", category: "Магазин косметики", logoAsset: "bell-logo"),
            images: ["company_cover"], // можно заменить на реальные ассеты
            text: "Новое поступление косметики в магазин Bellstore …",
            likes: 199,
            date: Calendar.current.date(byAdding: .hour, value: -2, to: .now) ?? .now
        )
    ]
}
