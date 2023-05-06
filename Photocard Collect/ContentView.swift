import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            FolderList()
                .navigationTitle("Photocard Collection")
                .accentColor(Color(hex: "FF2E98"))
        }
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
