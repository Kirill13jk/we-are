import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isOnboardingDone: Bool {
        didSet { UserDefaults.standard.set(isOnboardingDone, forKey: "onboarding_done") }
    }
    @Published var isAuthorized: Bool {
        didSet { UserDefaults.standard.set(isAuthorized, forKey: "is_authorized") }
    }

    init() {
        self.isOnboardingDone = UserDefaults.standard.bool(forKey: "onboarding_done")
        self.isAuthorized     = UserDefaults.standard.bool(forKey: "is_authorized")
    }
}
