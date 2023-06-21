import FirebaseAuth
import SwiftUI

class AuthenticationService: ObservableObject {
    private var auth: Auth?
    @Published var user: User?
    @Published var errorMessage: String?
    var userData: UserData?
    var isSignedIn: Bool { return user != nil }

    func configure() {
        auth = Auth.auth()
        auth?.addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
            }
        }
    }

    init() {
        configure()
    }

    func signIn(email: String, password: String) {
        guard let auth = auth else { return }
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else {
                self?.errorMessage = "Failed to sign in with error: \(error!.localizedDescription)"
                return
            }
            
            guard let user = result?.user else {
                self?.errorMessage = "Failed to retrieve user."
                return
            }
            
            if user.isEmailVerified {
                DispatchQueue.main.async {
                    self?.user = user
                    self?.errorMessage = nil
                }
            } else {
                self?.errorMessage = "Email is not verified. Please verify your email."
            }
        }
    }

    func signOut() {
        guard let auth = auth else { return }
        try? auth.signOut()
    }
    
    func sendPasswordReset(email: String) {
        guard let auth = auth else { return }
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = "Failed to send password reset email with error: \(error.localizedDescription)"
            } else {
                self.errorMessage = "Password reset email sent."
            }
        }
    }

    func signUp(email: String, password: String) {
        guard let auth = auth else { return }
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                self?.errorMessage = "Failed to sign up with error: \(error!.localizedDescription)"
                return
            }

            result?.user.sendEmailVerification { error in
                if let error = error {
                    self?.errorMessage = "Failed to send verification email with error: \(error.localizedDescription)"
                } else {
                    self?.errorMessage = "Verification email sent."
                }
            }

            DispatchQueue.main.async {
                if let user = result?.user {
                    self?.user = user
                    let userId = user.uid
                    self?.userData?.createUserDocument(for: userId)
                }
            }
        }
    }
}
