import UIKit
import Combine

final class ProfileModel: ObservableObject {
    @Published var firstName: String = "Kirill"
    @Published var lastName:  String = "Gneusev"
    @Published var middleName: String = "Yurevich"
    @Published var email: String = "skillhub@gmail.com"
    @Published var avatar: UIImage? = nil
    @Published var rating: Double = 4.0
    
    @Published var skills: [String] = []

    @Published var workplaces: [Workplace] = []
    
    @Published var languages: [LanguageSkill] = [
        .init(language: .init(code: "ru", name: "Русский"), level: .c2) // пример «Русский — Родной»
    ]

    private enum Keys {
        static let firstName = "profile.firstName"
        static let lastName  = "profile.lastName"
        static let middle    = "profile.middleName"
        static let email     = "profile.email"
        static let avatar    = "profile.avatar.jpeg"
        static let rating    = "profile.rating"
        static let works     = "profile.workplaces.json"   // NEW
    }

    init() { load() }

    func load() {
        let d = UserDefaults.standard
        firstName  = d.string(forKey: Keys.firstName) ?? firstName
        lastName   = d.string(forKey: Keys.lastName)  ?? lastName
        middleName = d.string(forKey: Keys.middle)    ?? middleName
        email      = d.string(forKey: Keys.email)     ?? email
        rating     = d.double(forKey: Keys.rating) == 0 ? rating : d.double(forKey: Keys.rating)
        if let data = d.data(forKey: Keys.avatar), let img = UIImage(data: data) { avatar = img }

        // NEW: загрузка опыта работы
        if let data = d.data(forKey: Keys.works),
           let arr = try? JSONDecoder().decode([Workplace].self, from: data) {
            workplaces = arr
        }
    }

    func persist() {
        let d = UserDefaults.standard
        d.set(firstName,  forKey: Keys.firstName)
        d.set(lastName,   forKey: Keys.lastName)
        d.set(middleName, forKey: Keys.middle)
        d.set(email,      forKey: Keys.email)
        d.set(rating,     forKey: Keys.rating)
        if let data = avatar?.jpegData(compressionQuality: 0.9) {
            d.set(data, forKey: Keys.avatar)
        } else {
            d.removeObject(forKey: Keys.avatar)
        }

        // NEW: сохранение опыта работы
        if let data = try? JSONEncoder().encode(workplaces) {
            d.set(data, forKey: Keys.works)
        }
    }

    var displayName: String { firstName }
    var fullName: String { [lastName, firstName, middleName].filter { !$0.isEmpty }.joined(separator: " ") }
}
