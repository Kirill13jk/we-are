import SwiftUI
import SwiftData

@main
struct WeAreApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var profile = ProfileModel()
    @StateObject private var notifications = NotificationsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(profile)
                .environmentObject(notifications)   // ← важно
        }
    }
}
