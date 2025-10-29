// AllCompaniesView.swift
import SwiftUI

struct AllCompaniesView: View {
    var companies: [Company]

    var body: some View {
        List {
            Section {
                ForEach(companies) { c in
                    NavigationLink {
                        CompanyScreen(company: c)
                    } label: {
                        CompanyRowStandard(company: c)   // стандартный ряд
                    }
                }
            }
        }
        .listStyle(.insetGrouped)                 // стандартная карточная группа iOS
        .navigationTitle("Все компании")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Стандартная строка без кастомных контейнеров/оверлеев
private struct CompanyRowStandard: View {
    let company: Company

    var body: some View {
        HStack(spacing: 12) {
            Avatar(logoAsset: company.logoAsset)
            VStack(alignment: .leading, spacing: 4) {
                Text(company.name)
                    .font(.body.weight(.semibold))
                Text(company.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer() // стрелку рисует NavigationLink сам — она окажется ВНУТРИ ячейки
        }
        .padding(.vertical, 6) // приятная высота тапа
    }

    private struct Avatar: View {
        let logoAsset: String?
        var body: some View {
            ZStack {
                if let n = logoAsset, UIImage(named: n) != nil {
                    Image(n).resizable().scaledToFill()
                } else {
                    Image(systemName: "building.2")
                        .resizable().scaledToFit()
                        .padding(8)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 52, height: 52)
            .background(Color(.systemGray6))
            .clipShape(Circle())
        }
    }
}
