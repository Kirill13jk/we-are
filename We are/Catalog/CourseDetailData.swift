import SwiftUI

// MARK: - Модели данных для JSON

struct CourseDetailData: Decodable {
    let title: String
    let image: String?
    let about: String?
    let durationHours: Int?
    var modules: [CourseModule]
    var reviews: [CourseReview]
}

struct CourseModule: Decodable, Identifiable {
    let idx: Int
    let title: String
    let subtitle: String
    var id: Int { idx }
}

struct CourseReview: Decodable, Identifiable {
    let author: String
    let text: String
    let dateString: String
    let rating: Int
    let id = UUID()
    
    private enum CodingKeys: String, CodingKey {
        case author, text, dateString, rating
    }
}

// MARK: - Провайдер: находит файл course_<slug>.json и парсит

enum CourseDetailProvider {
    /// Явные соответствия "название карточки" -> "slug"
    static let lookup: [String: String] = [
        "Курсы “SMM”": "smm",
        "Курсы SMM": "smm",
        "Курсы “English”": "english",
        "Курсы “Лидерства”": "leadership"
    ]

    static func load(for course: CourseItem) -> CourseDetailData? {
        let slug = lookup[course.title] ?? makeSlug(from: course.title)
        let fileName = "course_\(slug)"   // -> course_smm.json, course_english.json и т.п.

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("CourseDetailProvider: file not found:", fileName)
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(CourseDetailData.self, from: data)
            return decoded
        } catch {
            print("CourseDetailProvider decode error:", error)
            return nil
        }
    }

    /// Примитивный генератор slug из заголовка "Курсы “SMM”" -> "smm"
    private static func makeSlug(from title: String) -> String {
        let t = title.lowercased()
        if let l = t.firstIndex(of: "«") ?? t.firstIndex(of: "“"),
           let r = t.firstIndex(of: "»") ?? t.firstIndex(of: "”"),
           l < r {
            return String(t[t.index(after: l)..<r]).replacingOccurrences(of: " ", with: "_")
        }
        return t.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .joined(separator: "_")
    }
}
