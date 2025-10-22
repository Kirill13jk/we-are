import Foundation

// Отображаемый язык
struct LanguageOption: Identifiable, Hashable, Codable {
    let code: String
    let name: String
    var id: String { code }   // стабильный id
}

// CEFR + родной
enum ProficiencyLevel: String, CaseIterable, Identifiable, Codable {
    case a1, a2, b1, b2, c1, c2, native
    var id: String { rawValue }

    var title: String {
        switch self {
        case .a1: return "A1-Начальный"
        case .a2: return "A2-Элементарный"
        case .b1: return "B1-Средний"
        case .b2: return "B2-Средний-продвинутый"
        case .c1: return "C1-Продвинутый"
        case .c2: return "C2-В совершенстве"
        case .native: return "Родной"
        }
    }

    var shortLabel: String { self == .native ? "Родной" : rawValue.uppercased() }
}

// Связка «язык + уровень»
struct LanguageSkill: Identifiable, Hashable, Codable {
    var language: LanguageOption
    var level: ProficiencyLevel
    var id: String { language.code }       // идентификатор по коду языка
}

// ЕДИНЫЙ список языков
extension LanguageOption {
    static let all: [LanguageOption] = [
        .init(code: "ru", name: "Русский"),
        .init(code: "uz", name: "O'zbek"),
        .init(code: "uk", name: "Український"),
        .init(code: "kk", name: "Qazaq"),
        .init(code: "az", name: "Azərbaycan"),
        .init(code: "be", name: "Беларусскі"),
        .init(code: "tg", name: "Тоҷикӣ"),
        .init(code: "ro", name: "Română"),
        .init(code: "hy", name: "Հայերեն"),
        .init(code: "tk", name: "Türkmenler"),
        .init(code: "et", name: "Eesti"),
        .init(code: "la", name: "Latinus"),
        .init(code: "sv", name: "Svenska"),
        .init(code: "en", name: "English"),
    ]
}
