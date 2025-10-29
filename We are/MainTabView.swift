import SwiftUI

enum Tab: Hashable { case main, catalog, profile }

struct MainTabView: View {
    @State private var selected: Tab = .main
    @StateObject private var notifications = NotificationsStore()   // ← добавили

    var body: some View {
        TabView(selection: $selected) {

            NavigationStack { HomeScreen() }
                .tabItem {
                    Label("Главный", systemImage: selected == .main ? "house.fill" : "house")
                }
                .tag(Tab.main)

            NavigationStack { CatalogScreen() }
                .tabItem {
                    Label("Каталог", systemImage: selected == .catalog ? "square.grid.2x2.fill" : "square.grid.2x2")
                }
                .tag(Tab.catalog)

            NavigationStack { ProfileScreen() }
                .tabItem {
                    Label("Профиль", systemImage: selected == .profile ? "person.fill" : "person")
                }
                .tag(Tab.profile)
            
            HRScreen()
                .tabItem { Label("HR", systemImage: "person.2.fill") }
        }
        .environmentObject(notifications)
        .tint(.accentColor)
    }
}
