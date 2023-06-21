import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if authService.isSignedIn {
                Text("Logged in as \(authService.user?.email ?? "")")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                HStack(spacing: 20) {
                    Button(action: {
                            authService.sendPasswordReset(email: authService.user?.email ?? "")
                        }) {
                            HStack {
                                Text("Reset Password")
                            }
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    
                    Button(action: {
                                    authService.signOut()
                    }) {
                        HStack {
                            Text("Sign Out")
                        }
                    }
                    .padding()
                    .background(Constants.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }

            } else {
                Text("Account Center")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                TextField("Email", text: $email)
                    .font(.title2)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding([.leading, .trailing])
                
                SecureField("Password", text: $password)
                    .font(.title2)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding([.leading, .trailing])
                
                HStack(spacing: 20) {
                    Button(action: {
                            authService.signUp(email: email, password: password)
                        }) {
                            HStack {
                                Text("Sign Up")
                            }
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    
                    Button(action: {
                        authService.signIn(email: email, password: password)
                    }) {
                        HStack {
                            Text("Sign In")
                        }
                    }
                    .padding()
                    .background(Constants.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
            }
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
