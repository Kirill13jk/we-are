import SwiftUI
import PhotosUI

#if canImport(UIKit)
import UIKit
enum ImageAsset {
    static func exists(_ name: String) -> Bool { UIImage(named: name) != nil }
}
#else
enum ImageAsset {
    static func exists(_ name: String) -> Bool { false }
}
#endif


struct ProfileScreen: View {
    @State private var rating: Double = 4.0    
    @State private var certificates: [Certificate] = []
    @State private var pickedItems: [PhotosPickerItem] = []
    
    @State private var companies: [Company] = Company.demoList
    
    @EnvironmentObject private var profile: ProfileModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: Профиль — аватар, имя, почта
                    VStack(spacing: 8) {
                        if let img = profile.avatar {
                            Image(uiImage: img)
                                .resizable().scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable().scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                                .foregroundStyle(.secondary)
                        }

                        Text([profile.firstName, profile.lastName]
                                .filter { !$0.isEmpty }
                                .joined(separator: " "))
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.accentColor)


                        Text(profile.email)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)


                    // MARK: Рейтинг (без числа)
                    HStack(spacing: 12) {
                        Text("Рейтинг сотрудника")
                            .font(.headline)
                        Spacer()
                        StarsView(rating: rating)      // ← только звезды
                    }
                    .padding(.horizontal, 20)

                    // MARK: Быстрые действия
                    HStack(spacing: 12) {
                        QuickAction(icon: "bookmark",           title: "Избранное") { }
                        QuickAction(icon: "qrcode.viewfinder",   title: "Сканер") { }
                        QuickAction(icon: "text.bubble",         title: "Мои отзывы") { }
                        QuickAction(icon: "dollarsign.circle",   title: "Чаевые") { }
                    }
                    .padding(.horizontal, 20)

                    // MARK: Текущее место работы
                    SectionHeader("Текущее место работы").padding(.horizontal, 20)
                    if companies.isEmpty {
                        // пустое состояние
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Пока нет текущих мест работы").font(.headline)
                                Text("Добавьте компанию, и она появится в профиле.")
                                    .font(.callout).foregroundStyle(.secondary)
                                Button {
                                    // TODO: экран/форма добавления компании
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle")
                                        Text("Добавить место работы")
                                    }
                                    .font(.headline)
                                    .tint(.accentColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    
                    } else {
                        VStack(spacing: 12) {
                            ForEach(companies) { company in
                                NavigationLink {
                                    CompanyScreen(company: company)
                                } label: {
                                    Card {
                                        HStack(spacing: 12) {
                                            Group {
                                                if let n = company.logoAsset, ImageAsset.exists(n) {
                                                    Image(n).resizable().scaledToFill()
                                                } else {
                                                    Image(systemName: "building.2")
                                                        .resizable().scaledToFit()
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .frame(width: 64, height: 64)
                                            .background(Color(.systemGray5))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(company.name).font(.headline)
                                                HStack {
                                                    Text("Должность:").foregroundStyle(.secondary)
                                                    Text("Стажер").foregroundStyle(Color.accentColor)
                                                }.font(.subheadline)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                                        }
                                    }
                                    .padding(.horizontal, 20)

                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // MARK: Данные
                    SectionHeader("Данные").padding(.horizontal, 20)
                    NavigationLink {
                        ProfileDataView()
                    } label: {
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(profile.fullName)
                                Text(profile.email).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)

                    // MARK: Опыт работы
                    SectionHeader("Опыт работы").padding(.horizontal, 20)
                    if profile.workplaces.isEmpty {
                        Card {
                            HStack {
                                Text("Пока пусто").foregroundStyle(.secondary)
                                Spacer()
                                NavigationLink("Добавить") { WorkExperienceListView() }
                                    .font(.headline)
                            }
                        }.padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(profile.workplaces.prefix(2)) { w in
                                Card { WorkplaceCard(work: w) }
                            }
                            NavigationLink { WorkExperienceListView() } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle")
                                    Text("Добавить место работы")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.headline)
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                    }

                    // MARK: Ключевые навыки
                    SectionHeader("Ключевые навыки").padding(.horizontal, 20)
                    Card {
                        VStack(alignment: .leading, spacing: 6) {
                            Bullet("Умение работать с кассовым аппаратом")
                            Bullet("Опыт консультирования покупателей")
                            Bullet("Опыт приёма и выкладки товара")
                            Bullet("Навыки продажи товара")
                            Bullet("Навыки ведения отчетности")
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: Владение языками
                    SectionHeader("Владение языками").padding(.horizontal, 20)
                    Card {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Русский — Родной")
                                Spacer()
                            }
                            Divider().opacity(0.15)
                            Button {
                                // TODO: открыть модалку выбора языка
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle").foregroundStyle(Color.accentColor)
                                    Text("Добавить язык").foregroundStyle(Color.accentColor)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: Сертификаты
                    SectionHeader("Сертификаты").padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // + Добавить (галерея)
                            PhotosPicker(selection: $pickedItems, maxSelectionCount: 5, matching: .images) {
                                AddCertificateCard()
                            }
                            .onChange(of: pickedItems) { _, newItems in
                                Task {
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let ui = UIImage(data: data) {
                                            certificates.append(.init(id: .init(),
                                                                      title: "Сертификат",
                                                                      modules: 20,
                                                                      progress: 0.95,
                                                                      image: ui))
                                        }
                                    }
                                    pickedItems.removeAll()
                                }
                            }

                            ForEach(certificates) { cert in
                                CertificateCard(cert: cert)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 12)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: settingsTapped) {
                        Image("setting-2")
                            .renderingMode(.original)
                            .resizable().scaledToFit()
                            .frame(width: 22, height: 22)
                            .accessibilityLabel("Настройки")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: qrTapped) {
                        Image("qr_code_24")
                            .renderingMode(.original)
                            .resizable().scaledToFit()
                            .frame(width: 22, height: 22)
                            .accessibilityLabel("QR")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


private func settingsTapped() {
    // TODO: открыть экран настроек
}

private func qrTapped() {
    // TODO: открыть экран QR
}


// MARK: - Models
struct Certificate: Identifiable, Equatable {
    let id: UUID
    var title: String
    var modules: Int
    var progress: Double // 0...1
    var image: UIImage?
}

private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct QuickAction: View {
    var icon: String
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.accentColor)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                Text(title).font(.footnote)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct StarsView: View {
    let rating: Double // 0...5
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                let fill = max(0, min(1, rating - Double(i)))
                Star(fill: fill)
                    .frame(width: 18, height: 18)
                    .foregroundStyle(fill > 0 ? Color.yellow : Color(.systemGray4))
            }
        }
    }
}

private struct Star: View {
    let fill: Double // 0…1
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "star")
            Image(systemName: "star.fill")
                .mask(GeometryReader { geo in
                    Rectangle().frame(width: geo.size.width * fill)
                })
        }
    }
}

private struct Bullet: View {
    var text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().frame(width: 6, height: 6).foregroundStyle(.secondary).padding(.top, 6)
            Text(text)
        }
        .font(.callout)
    }
}

private struct AddCertificateCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                .foregroundStyle(Color.accentColor.opacity(0.6))
                .frame(width: 220, height: 120)
                .overlay(Image(systemName: "plus").font(.title).foregroundStyle(Color.accentColor))
            Text("Добавить").font(.headline)
            Text("Загрузите изображение сертификата")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

private struct CertificateCard: View {
    let cert: Certificate
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let ui = cert.image {
                Image(uiImage: ui)
                    .resizable().scaledToFill()
                    .frame(width: 220, height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 220, height: 120)
                    .overlay(Text("Нет изображения").font(.caption).foregroundStyle(.secondary))
            }
            Text(cert.title).font(.headline)
            HStack {
                Text("Модулей: \(cert.modules)")
                Spacer()
                Text("Прогресс \(Int(cert.progress * 100))%").foregroundStyle(.green)
            }
            .font(.footnote)
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                Text("Скачать")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.accentColor)
        }
        .padding(12)
        .frame(width: 240, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}
