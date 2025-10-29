import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.autoDownload") private var autoDownload = false
    @AppStorage("settings.notificationsOff") private var notificationsOff = false
    @Environment(\.openURL) private var openURL

    var openAbout: () -> Void

    var body: some View {
        List {
            Section {
                Toggle("Автозагрузка", isOn: $autoDownload)
                Text("Загружать назначенные файлы автоматически при наличии Wi-Fi")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            Section {
                Toggle("Отключить уведомления", isOn: $notificationsOff)
            }

            Section {
                Button("Открыть в браузере") {
                    openURL(URL(string: "https://example.com")!)
                }
                Button("О приложении") { openAbout() }
            }

            Section {
                Button(role: .destructive) { /* TODO: signOut */ } label: { Text("Выйти") }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct AboutAppView: View {
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Link(destination: URL(string: "https://facebook.com")!)   { Image(systemName: "globe").font(.title3) }
                    Link(destination: URL(string: "https://instagram.com")!)  { Image(systemName: "camera").font(.title3) }
                    Link(destination: URL(string: "https://t.me")!)           { Image(systemName: "paperplane").font(.title3) }
                    Link(destination: URL(string: "tel:+998900000000")!)      { Image(systemName: "phone") .font(.title3) }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 6)
            }

            Section {
                Link("Написать в поддержку", destination: URL(string: "mailto:support@example.com")!)
                Link("Условия пользования",   destination: URL(string: "https://example.com/terms")!)
                Link("Условия конфиденциальности", destination: URL(string: "https://example.com/privacy")!)
            }

            Section {
                HStack { Spacer(); Text("Версия 1.0 (000)").foregroundStyle(.secondary); Spacer() }
            }
        }
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.inline)
    }
}
