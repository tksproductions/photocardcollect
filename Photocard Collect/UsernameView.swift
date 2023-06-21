import SwiftUI

struct UsernameView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Binding var isPresented: Bool
    @State var username = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter a Username")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            TextField("Username", text: $username)
                .font(.title2)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding([.leading, .trailing])
            
            HStack(spacing: 20) {
                Button(action: {
                    //authService.setUsername(username: username)
                    isPresented = false
                }) {
                    HStack {
                        Text("Confirm")
                    }
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(15)
                
                Button(action: {
                    isPresented = false
                }) {
                    HStack {
                        Text("Cancel")
                    }
                }
                .padding()
                .background(Constants.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
        }
        .padding()
    }
}
