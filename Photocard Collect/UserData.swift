import Firebase
import FirebaseFirestoreSwift
import Combine

class UserData: ObservableObject {
    @Published var folders: [Folder] = []
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

    public func saveFolders() {
        guard let userId = authService?.user?.uid else {
            return
        }

        guard let db = db else {
            return
        }

        for folder in folders {
            do {
                let folderData = try Firestore.Encoder().encode(folder)
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

    private func loadFolders(for userId: String?) {
        guard let userId = userId, let db = db else {
            return
        }

        db.collection("users").document(userId).collection("folders").getDocuments { [weak self] (querySnapshot, error) in
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

    func createUserDocument(for userId: String) {
        guard let db = db else {
            return
        }

        let ref = db.collection("users").document(userId)
        ref.setData(["folders": []]) { error in
            if let error = error {
                print("Error creating user document: \(error)")
            } else {
                print("User document successfully created!")
            }
        }
    }
}
