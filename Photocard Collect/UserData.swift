import Firebase
import FirebaseFirestoreSwift
import Combine

class UserData: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var username: String = ""
    private var db: Firestore?
    private var cancellables: Set<AnyCancellable> = []
    private var authService: AuthenticationService?

    init() {}

    func setup(with authService: AuthenticationService) {
        self.authService = authService
        db = Firestore.firestore()
        
        authService.$user
            .sink { [weak self] user in
                if let userId = user?.uid {
                    self?.loadFolders(for: userId)
                    self?.loadUsername(for: userId)
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.saveFolders()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.saveFolders()
            }
            .store(in: &cancellables)
        
        
    }

    func loadFoldersFromUserDefaults() -> [Folder] {
        let folderKey = "folders"
        if let folderData = UserDefaults.standard.data(forKey: folderKey),
           let decodedFolders = try? JSONDecoder().decode([Folder].self, from: folderData) {
            return decodedFolders
        }
        return []
    }

    private func loadFolders(for userId: String?) {
        guard let userId = userId, let db = db else {
            return
        }

        db.collection("users").document(userId).collection("folders").order(by: "orderIndex").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting folders: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.folders = querySnapshot?.documents.compactMap { document -> Folder? in
                        try? Firestore.Decoder().decode(Folder.self, from: document.data())
                    } ?? []
                }
            }
        }
    }

    public func saveFolders() {
        guard let userId = authService?.user?.uid, let db = db else {
            return
        }

        // First, delete all existing folders
        db.collection("users").document(userId).collection("folders").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }

                // Then, add the new folders
                for (index, folder) in self.folders.enumerated() {
                    do {
                        var folderData = try Firestore.Encoder().encode(folder)
                        folderData["orderIndex"] = index
                        db.collection("users").document(userId).collection("folders").document(folder.id.uuidString).setData(folderData) { error in
                            if let error = error {
                                print("Error writing folder to Firestore: \(error)")
                            } else {
                                print("Folder saved to Firestore successfully!")
                            }
                        }
                    } catch let error {
                        print("Error encoding folder data: \(error)")
                    }
                }
            }
        }
    }


    private func loadUsername(for userId: String?) {
        guard let userId = userId, let db = db else {
            return
        }

        db.collection("users").document(userId).getDocument { [weak self] (documentSnapshot, error) in
            if let error = error {
                print("Error getting username: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.username = documentSnapshot?.data()?["username"] as? String ?? ""
                }
            }
        }
    }
    
    public func saveUsername(for username: String) {
        guard let userId = authService?.user?.uid else {
            return
        }

        guard let db = db else {
            return
        }

        db.collection("users").document(userId).updateData(["username": username]) { error in
            if let error = error {
                print("Error writing username to Firestore: \(error)")
            } else {
                print("Username saved to Firestore successfully!")
                self.username = username
            }
        }
    }
    
    func clearFoldersFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "folders")
    }

    func createUserDocument(for userId: String) {
        guard let db = db else {
            return
        }

        let ref = db.collection("users").document(userId)
        ref.setData(["folders": []]) { [weak self] error in
            if let error = error {
                print("Error creating user document: \(error)")
            } else {
                print("User document successfully created!")

                self?.folders = self?.loadFoldersFromUserDefaults() ?? []
                self?.saveFolders()
                self?.clearFoldersFromUserDefaults()
            }
        }
    }
    
    func isUsernameAvailable(_ username: String, completion: @escaping (Bool) -> Void) {
        let usernameRegex = "^[a-z0-9_.]{2,}$"
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegex)
        guard usernamePred.evaluate(with: username) else {
            completion(false)
            return
        }

        db?.collection("users").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                if querySnapshot!.documents.count > 0 {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
