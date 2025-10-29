import Foundation

struct Course: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var tag: String       // например: "#Рестораны"
    var lessons: Int
    var imageAsset: String
}

extension Course {
    static func demo(for company: Company) -> [Course] {
        [
            .init(title: "Для Официанта", tag: "#Рестораны", lessons: 19, imageAsset: "yapo-1"),
            .init(title: "Для Хостес",     tag: "#Рестораны", lessons: 12, imageAsset: "yapo-2"),
            .init(title: "Для Официанта", tag: "#Рестораны", lessons: 19, imageAsset: "yapo-3"),
            .init(title: "Для Хостес",     tag: "#Рестораны", lessons: 12, imageAsset: "yapo-4"),
        ]
    }
}
