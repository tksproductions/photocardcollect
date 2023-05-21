import SwiftUI
@main
struct Photocard_CollectApp: App {
    @StateObject private var lifecycleListener = AppLifecycleListener()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lifecycleListener)
        }
    }
}
