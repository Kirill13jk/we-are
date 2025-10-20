import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                Text("Главный").font(.title)
            }
            .navigationTitle("Главный")
        }
    }
}

struct CatalogScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                Text("Каталог").font(.title)
            }
            .navigationTitle("Каталог")
        }
    }
}

