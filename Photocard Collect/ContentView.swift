import SwiftUI
import StoreKit

struct ContentView: View {
    @EnvironmentObject var lifecycleListener: AppLifecycleListener
    let appStoreURL = URL(string: "https://apps.apple.com/us/app/pcollect/id6448884412")!
    
    var body: some View {
        NavigationView {
            FolderList()
                .navigationTitle("Photocard Collection")
                .alert(isPresented: $lifecycleListener.showAlert) {
                    Alert(
                        title: Text("Support PCollect?"),
                        message: Text("Help us keep PCollect free! Would you like to support us with a small donation?"),
                        primaryButton: .default(Text("Yes"), action: {
                            if let url = URL(string: "https://www.buymeacoffee.com/pcollect"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }),
                        secondaryButton: .cancel(Text("No"))
                    )
                }
        }
    }
}

extension AppLifecycleListener {
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        self.init(red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: Double(rgbValue & 0x0000FF) / 255.0)
    }
}

