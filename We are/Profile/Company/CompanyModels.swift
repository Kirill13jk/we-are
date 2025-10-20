import SwiftUI

// MARK: - Models

struct Company: Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var logoAsset: String?     // имя ассета лого
    var coverAsset: String?    // имя ассета обложки
    var posts: Int
    var followers: Int
    var socials: [SocialLink]
    var about: String
    var contacts: CompanyContacts
    var news: [NewsItem]
    var rating: Double         // средняя оценка 0…5
    var histogram: [Int]       // [5★,4★,3★,2★,1★]
    var reviews: [Review]
    var isFollowed: Bool
}

struct SocialLink: Identifiable, Hashable {
    let id = UUID()
    var type: SocialType
    var url: URL?
}
enum SocialType: String, CaseIterable { case facebook, instagram, telegram, website }

struct CompanyContacts: Hashable {
    var phone1: String?
    var phone2: String?
    var address: String?
}

struct NewsItem: Identifiable, Hashable {
    let id = UUID()
    var imageAsset: String     // имя ассета
}

struct Review: Identifiable, Hashable {
    let id = UUID()
    var author: String
    var date: Date
    var text: String
    var rating: Int            // 1…5
}

// MARK: - Demo

extension Company {
    static let demo: Company = .init(
        id: .init(),
        name: "Bellstore",
        category: "Магазин косметики",
        logoAsset: "company_logo",      // добавь ассеты при желании
        coverAsset: "company_cover",
        posts: 8,
        followers: 140,
        socials: [
            .init(type: .facebook,  url: URL(string: "https://facebook.com")),
            .init(type: .instagram, url: URL(string: "https://instagram.com")),
            .init(type: .telegram,  url: URL(string: "https://t.me")),
            .init(type: .website,   url: URL(string: "https://example.com"))
        ],
        about: """
Lorem ipsum dolor sit amet, consectetur adipisicing elit. Viverra habitant lacus, auctor nulla nec cursus.
""",
        contacts: .init(phone1: "+998 99 999 99 99",
                        phone2: "+998 99 999 99 99",
                        address: "ул. Тараса Шевченко, дом 27"),
        news: (1...9).map { _ in .init(imageAsset: "news_placeholder") },
        rating: 4.8,
        histogram: [12, 4, 2, 0, 1],
        reviews: [
            .init(author: "Виктор", date: .now.addingTimeInterval(-86400.0 * 370.0),
                  text: "Отличный сервис и консультация.", rating: 5),
            .init(author: "Дарья", date: .now.addingTimeInterval(-86400.0 * 360.0),
                  text: "Большой выбор, иногда очереди.", rating: 4)
        ],
        isFollowed: true
    )

    static let demoList: [Company] = [Company.demo] // можно добавить больше
}
