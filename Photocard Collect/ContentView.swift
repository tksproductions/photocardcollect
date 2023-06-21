import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var lifecycleListener: AppLifecycleListener
    @State private var showUpdateAlert = false
    let appStoreURL = URL(string: "https://apps.apple.com/us/app/pcollect/id6448884412")!
    @EnvironmentObject var userData: UserData

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
                .alert(isPresented: $showUpdateAlert) {
                    Alert(
                        title: Text("New update!"),
                        message: Text("Please update to the latest version of PCollect!"),
                        dismissButton: .default(Text("OK"), action: {
                            UIApplication.shared.open(appStoreURL)
                        })
                    )
                }
        }
        .onAppear {
            authService.configure()
            authService.userData = userData
            userData.setup(with: authService)
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

