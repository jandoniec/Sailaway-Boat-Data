import SwiftUI

struct LoginView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false
    @State private var boats: [Boat] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("Sailaway Login")
                    .font(.largeTitle)
                    .padding(.bottom, 40)

                TextField("Username (usrnr)", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                SecureField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: login) {
                    Text("Log In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Spacer()

                NavigationLink(
                    destination: BoatSelectionView(username: username, apiKey: apiKey),
                    isActive: $isLoggedIn
                ) {
                    EmptyView()
                }
                .navigationBarBackButtonHidden(true) // Ukrycie przycisku "Back"


            }
            .padding()
        }
    }

    private func login() {
        let sanitizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !sanitizedUsername.isEmpty, !sanitizedApiKey.isEmpty else {
            errorMessage = "Both fields are required."
            return
        }

        APIService.fetchBoats(username: sanitizedUsername, apiKey: sanitizedApiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedBoats):
                    self.boats = fetchedBoats
                    self.isLoggedIn = true
                    saveLoginData(username: sanitizedUsername, apiKey: sanitizedApiKey) // Zapisz dane
                case .failure(let error):
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func saveLoginData(username: String, apiKey: String) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
    }
}
