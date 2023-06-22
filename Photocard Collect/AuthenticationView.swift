import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var userData: UserData
    @State var email = ""
    @State var password = ""
    @State var newUsername = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Account Center")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            if authService.isSignedIn {
                HStack {
                    Text("Email:")
                        .font(.body)
                        .fontWeight(.bold)
                    Text(authService.user?.email ?? "")
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                
                if userData.username.isEmpty {
                    HStack {
                        TextField("Claim a username!", text: $newUsername)
                            .font(.title2)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .frame(height: 50)
                        Button(action: {
                            if authService.isEmailVerified() == true {
                                userData.isUsernameAvailable(newUsername) { available in
                                    if available {
                                        userData.saveUsername(for: newUsername)
                                    } else {
                                        authService.errorMessage = "This username is already taken or does not meet the requirements."
                                    }
                                }
                            } else {
                                authService.errorMessage = "Please verify your email first."
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 10)
                                .background(Color.gray)
                                .clipShape(Circle())
                        }
                    }
                } else {
                    HStack {
                        Text("Username:")
                            .font(.body)
                            .fontWeight(.bold)
                            .frame(alignment: .leading)
                        Text(userData.username)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .padding(.bottom)
                }
                HStack(spacing: 20) {
                    if authService.isEmailVerified() == true {
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
                    } else {
                        Button(action: {
                            authService.resendVerificationEmail()
                        }) {
                            HStack {
                                Text("Resend Email")
                            }
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
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
