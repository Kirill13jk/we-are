import SwiftUI

struct CompanyCoursesScreen: View {
    var company: Company
    var courses: [Course] = []

    init(company: Company) {
        self.company = company
        self.courses = Course.demo(for: company)   // чисто визуально
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // «шапка» экрана как на макете: иконка + заголовок
                HStack(spacing: 10) {
                    Image(systemName: "briefcase.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                    Text("Курсы компании")
                        .font(.title2).bold()
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                VStack(spacing: 14) {
                    ForEach(courses) { c in
                        CourseCard(course: c)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("") // чтобы заголовок был «плоским», как в примере
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CourseCard: View {
    var course: Course

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Картинка слева 4:3
            Group {
                if UIImage(named: course.imageAsset) != nil {
                    Image(course.imageAsset).resizable().scaledToFill()
                } else {
                    ZStack {
                        Rectangle().fill(Color(.secondarySystemBackground))
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 140, height: 94) // пропорция близка к примеру
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(course.title)
                    .font(.headline)

                Text(course.tag)
                    .font(.subheadline)
                    .foregroundStyle(.blue)

                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text("Уроков : \(course.lessons)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}
