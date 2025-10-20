import Foundation

struct Workplace: Identifiable, Codable, Equatable {
    var id: UUID = .init()
    var company: String = ""
    var position: String = ""
    var start: Date = Date()
    var end: Date? = nil          // nil = «по настоящее время»
    var rating: Double? = 4.3
    var verified: Bool = true
}

// Не обязателен, но удобно для подписи периода на карточке
enum WorkFmt {
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    static func period(_ start: Date, _ end: Date?) -> String {
        let cal = Calendar.current
        let to = end ?? Date()
        let comps = cal.dateComponents([.year, .month], from: start, to: to)
        let y = comps.year ?? 0, m = comps.month ?? 0
        var parts: [String] = []
        if y > 0 { parts.append("\(y) \(y == 1 ? "год" : (y < 5 ? "года" : "лет"))") }
        if m > 0 { parts.append("\(m) \(m == 1 ? "месяц" : (m < 5 ? "месяца" : "месяцев"))") }
        let dur = parts.isEmpty ? "" : " ( " + parts.joined(separator: " ") + " )"
        return "\(monthYear.string(from: start)) – \((end != nil) ? monthYear.string(from: to) : "по н.в.")\(dur)"
    }
}
