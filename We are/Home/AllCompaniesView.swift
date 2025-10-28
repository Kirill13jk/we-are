// AllCompaniesView.swift
import SwiftUI

#if canImport(UIKit)
import UIKit
enum ImageAsset_AllCompanies {
    static func exists(_ name: String) -> Bool { UIImage(named: name) != nil }
}
#else
enum ImageAsset_AllCompanies {
    static func exists(_ name: String) -> Bool { false }
}
#endif

struct AllCompaniesView: View {
    var companies: [Company] = Company.demoList

    var body: some View {
        List {
            ForEach(companies) { company in
                NavigationLink {
                    CompanyScreen(company: company)
                } label: {
                    CompanyRow(company: company, subtitle: subtitle(for: company))
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("Все компании")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Если в твоей модели есть поле вроде `category/description`,
    // просто подставь его; тут — демо-подзаголовок по имени
    private func subtitle(for c: Company) -> String {
        switch c.name.lowercased() {
        case _ where c.name.localizedCaseInsensitiveContains("yapon"):
            return "Японская кухня"
        case _ where c.name.localizedCaseInsensitiveContains("jowi"):
            return "Автоматизация ресторана"
        case _ where c.name.localizedCaseInsensitiveContains("bell"):
            return "Магазин косметики"
        case _ where c.name.localizedCaseInsensitiveContains("muna"):
            return "Маркетинговое агентство"
        default:
            return ""
        }
    }
}

// Карточка строки компании
private struct CompanyRow: View {
    var company: Company
    var subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let n = company.logoAsset, ImageAsset_AllCompanies.exists(n) {
                    Image(n).resizable().scaledToFill()
                } else {
                    Image(systemName: "building.2")
                        .resizable().scaledToFit()
                        .padding(10)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 56)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))

            VStack(alignment: .leading, spacing: 4) {
                Text(company.name).font(.headline)
                if !subtitle.isEmpty {
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}
