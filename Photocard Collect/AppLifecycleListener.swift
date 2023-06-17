import SwiftUI

// 1. AppLifecycleListener listens to app lifecycle notifications
class AppLifecycleListener: ObservableObject {
    @Published var showAlert = false

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func appDidBecomeActive() {
        showAlert = shouldAskToDonate()
    }

    private func shouldAskToDonate() -> Bool {
        return Int.random(in: 1...30) == 1
    }
}
