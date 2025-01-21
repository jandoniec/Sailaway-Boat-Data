import SwiftUI

struct LoginView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Sailaway Login")
                .font(.custom("BebasNeue", size: 40))
                .foregroundColor(.white)
                .padding(.top, 20)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()

            SecureField("API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(8)
            }

            Spacer()

            NavigationLink("", destination: BoatSelectionView(username: username, apiKey: apiKey), isActive: $isLoggedIn)
                .hidden()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private func login() {
        guard !username.isEmpty, !apiKey.isEmpty else {
            errorMessage = "Both fields are required."
            return
        }
        APIService.testLogin(username: username, apiKey: apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    saveCredentials()
                    isLoggedIn = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func saveCredentials() {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
    }
}
