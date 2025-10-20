import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isOnboardingDone {
                OnboardingView()
            } else if !appState.isAuthorized {
                LoginView()
            } else {
                MainTabView()
            }
        }
   
        .animation(.easeInOut, value: appState.isOnboardingDone)
        .animation(.easeInOut, value: appState.isAuthorized)
    }
}
