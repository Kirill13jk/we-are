import SwiftUI
import PhotosUI

struct ProfileScreen: View {
    @State private var rating: Double = 4.0
    @State private var certificates: [Certificate] = []
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var companies: [Company] = [Company.demoProfile]

    // Хранение языков в UserDefaults
    @AppStorage("profile.languages.v1") private var langsData: Data = Data()
    @State private var langs: [LanguageSkill] = []
    @State private var showAddLanguage = false

    @EnvironmentObject private var profile: ProfileModel
    
    @State private var path: [ProfileRoute] = []
    @State private var showQR = false

    enum ProfileRoute: Hashable { case settings, about }

    var body: some View {
        NavigationStack(path: $path) {
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

                        Text([profile.firstName, profile.lastName].filter{ !$0.isEmpty }.joined(separator: " "))
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)

                        Text(profile.email)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    // MARK: Рейтинг
                    HStack(spacing: 12) {
                        Text("Рейтинг сотрудника").font(.headline)
                        Spacer(minLength: 8)
                        StarsView(rating: rating)
                        Text(String(format: "%.1f", rating))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)

                    // MARK: Быстрые действия
                    HStack(spacing: 12) {
                        QuickAction(icon: "bookmark",         title: "Избранное") {}
                        QuickAction(icon: "qrcode.viewfinder", title: "Сканер") {}
                        QuickAction(icon: "text.bubble",       title: "Мои отзывы") {}
                        QuickAction(icon: "dollarsign.circle", title: "Чаевые") {}
                    }
                    .padding(.horizontal, 20)

                    // MARK: Текущее место работы
                    SectionHeader("Текущее место работы").padding(.horizontal, 20)
                    if companies.isEmpty {
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
                                                }
                                                .font(.subheadline)
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
                    NavigationLink { ProfileDataView() } label: {
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(profile.fullName)
                                Text(profile.email).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .overlay(alignment: .trailing) { AccessoryChip().padding(12) }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)

                    // MARK: Опыт работы
                    SectionHeader("Опыт работы").padding(.horizontal, 20)
                    NavigationLink { WorkExperienceListView() } label: {
                        TappableCard {
                            if profile.workplaces.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Пока нет опыта работы").font(.headline)
                                    Text("Нажмите, чтобы добавить место работы")
                                        .font(.callout).foregroundStyle(.secondary)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(profile.workplaces.prefix(2)) { w in
                                        WorkplaceCard(work: w) // без внутренней стрелки
                                    }
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    // MARK: Ключевые навыки
                    SectionHeader("Ключевые навыки").padding(.horizontal, 20)
                    NavigationLink { SkillsEditorView(skills: $profile.skills) } label: {
                        Card {
                            Group {
                                if profile.skills.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Пока пусто").foregroundStyle(.secondary)
                                        Text("Нажмите, чтобы добавить навыки")
                                            .font(.footnote).foregroundStyle(.tertiary)
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(profile.skills, id: \.self) { Bullet($0) }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .overlay(alignment: .trailing) { AccessoryChip().padding(12) }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)

                    // MARK: Владение языками
                    SectionHeader("Владение языками").padding(.horizontal, 20)
                    Card {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(langs) { item in
                                HStack {
                                    Text("\(item.language.name) — \(item.level == .native ? "Родной" : item.level.title)")
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                Divider().opacity(0.12)
                            }

                            Button { showAddLanguage = true } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle").foregroundStyle(Color.accentColor)
                                    Text("Добавить язык").foregroundStyle(Color.accentColor)
                                    Spacer()
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .sheet(isPresented: $showAddLanguage) {
                        LanguagesPickerView(existing: langs) { merged in
                            langs = merged
                        }
                    }


                    // MARK: Сертификаты
                    SectionHeader("Сертификаты").padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
                .onAppear { langs = decodeLangs(langsData) }
                .onChange(of: langs) { oldValue, newValue in
                    langsData = encodeLangs(newValue)
                }

            }
            .onAppear {
                // 1) грузим из UserDefaults (или дефолт Русский — Родной)
                langs = decodeLangs(langsData)
            }
            .onChange(of: langs) { oldValue, newValue in
                // 2) автосохранение без депрекейта
                langsData = encodeLangs(newValue)
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .settings:
                    SettingsView(openAbout: { path.append(.about) })
                case .about:
                    AboutAppView()
                }
            }
            .sheet(isPresented: $showQR) {
                QRSheet(
                    text: profile.email.isEmpty ? "skillhub@example.com" : profile.email,
                    avatar: profile.avatar
                )
            }

            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        path.append(.settings)
                    } label: {
                        if ImageAsset.exists("profile-settings") {
                            Image("profile-settings")
                                .renderingMode(.original)
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                        } else {
                            Image(systemName: "gearshape")
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    }
                    .accessibilityLabel("Настройки")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button { showQR = true } label: {
                        if ImageAsset.exists("profile-qr") {
                            Image("profile-qr")
                                .renderingMode(.original)
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                        } else {
                            Image(systemName: "qrcode")
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    }
                    .accessibilityLabel("QR")
                }
            }

        }
    }

    // MARK: Persistence helpers
    private func decodeLangs(_ data: Data) -> [LanguageSkill] {
        if !data.isEmpty, let arr = try? JSONDecoder().decode([LanguageSkill].self, from: data), !arr.isEmpty {
            return arr
        }
        // дефолт: Русский — Родной
        let ru = LanguageOption.all.first { $0.code == "ru" } ?? .init(code: "ru", name: "Русский")
        return [LanguageSkill(language: ru, level: .native)]
    }

    private func encodeLangs(_ arr: [LanguageSkill]) -> Data {
        (try? JSONEncoder().encode(arr)) ?? Data()
    }

}

// MARK: - Вспомогательные UI

private struct AccessoryChip: View {
    var icon: String = "chevron.right"
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            )
    }
}

private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.title3)
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
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 48, height: 48)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
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
            .font(.footnote)
            .foregroundStyle(Color.accentColor)
        }
        .padding(12)
        .frame(width: 240, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}


// MARK: - Прочие модели для экрана

struct Certificate: Identifiable, Equatable {
    let id: UUID
    var title: String
    var modules: Int
    var progress: Double
    var image: UIImage?
}


// MARK: - Шапка/навигация кнопки

private func settingsTapped() {
    // TODO: открыть экран настроек
}

private func qrTapped() {
    // TODO: открыть экран QR
}
