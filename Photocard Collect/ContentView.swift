import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            FolderList()
                .navigationTitle("Photocard Collection")
        }
    }
}
