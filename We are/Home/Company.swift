import Foundation

struct Company: Identifiable, Hashable {
    // Базовое
    var id: UUID = UUID()
    var name: String
    var category: String

    // Медиа
    var logoAsset: String? = nil
    var coverAsset: String? = nil

    // Профиль
    var posts: Int = 0
    var followers: Int = 0
    var socials: [SocialLink] = []
    var about: String = ""
    var contacts: CompanyContacts = .init()
    var news: [NewsItem] = []

    // Отзывы
    var rating: Double = 0
    /// Гистограмма в порядке: [5★,4★,3★,2★,1★]
    var histogram: [Int] = [0,0,0,0,0]
    var reviews: [Review] = []

    var isFollowed: Bool = false
}

struct SocialLink: Identifiable, Hashable {
    let id = UUID()
    var type: SocialType
    var url: URL?
}
enum SocialType: String, CaseIterable { case facebook, instagram, telegram, website }

struct CompanyContacts: Hashable {
    var phone1: String? = nil
    var phone2: String? = nil
    var address: String? = nil
}

struct NewsItem: Identifiable, Hashable {
    let id = UUID()
    var imageAsset: String
}

struct Review: Identifiable, Hashable {
    let id = UUID()
    var author: String
    var date: Date
    var text: String
    var rating: Int            // 1…5
}


extension Company {

    // Полный профиль Yaponamama
    static let demoProfile: Company = .init(
        name: "Yaponamama",
        category: "Японская кухня",
        logoAsset: "yapo-logo",         // добавь такой ассет
        coverAsset: "company_cover",     // добавь ассет обложки
        posts: 8,
        followers: 100,
        socials: [
            .init(type: .facebook,  url: URL(string: "https://facebook.com")),
            .init(type: .instagram, url: URL(string: "https://instagram.com")),
            .init(type: .telegram,  url: URL(string: "https://t.me")),
            .init(type: .website,   url: URL(string: "https://example.com"))
        ],
        about:
"""
Yaponamama — это паназиатская кухня Fusion.

Бренд Шеф повар соединил традиционную, многовековую практику приготовления суши с новшествами современного быта и ярких идей. Мы используем океаническую рыбу как основу здорового питания и вкладываем частичку своей души в приготовление каждого заказа! Наши цели — воспитывать удовольствие от потребляемой пищи и мы двигаемся в верном направлении.
""",
        contacts: .init(
            phone1: "+998 99 999 99 99",
            phone2: "+998 99 999 99 99",
            address: "Адрес: ул.Тараса Шевченко дом 12"
        ),
        // если ассетов нет — отрисуются плейсхолдеры, это ок
        news: (1...9).map { .init(imageAsset: "yapo-\($0)") },
        rating: 5.0,
        // для экрана отзывов (как на макете 4)
        histogram: [4, 0, 0, 0, 0],
        reviews: [
            .init(
                author: "Виктор",
                date: Calendar.current.date(byAdding: .day, value: -1234, to: .now) ?? .now,
                text: "Работал в Yaponamama менеджером, воспоминания только положительные, сейчас же часто бываю там уже как гость…",
                rating: 5
            ),
            .init(
                author: "Дарья",
                date: Calendar.current.date(byAdding: .day, value: -1230, to: .now) ?? .now,
                text: "Я работаю в Yaponamama официанткой, замечательное заведение, хороший персонал. Единственное — бывает большая загруженность 🙂",
                rating: 5
            )
        ],
        isFollowed: false
    )

    /// Короткий список для «Главная»/«Все компании»
    static let demoList: [Company] = [
        .demoProfile, // ← заполненная Yaponamama
        .init(name: "Bellstore",  category: "Магазин косметики",       logoAsset: "bell-logo"),
        .init(name: "Jowi",       category: "Автоматизация ресторана", logoAsset: "jowi-logo"),
        .init(name: "MUNA",       category: "Маркетинговое агентство", logoAsset: "muna-logo")
    ]
}
