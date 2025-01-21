//
//  BoatSelectionView.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//


//
//  BoatSelectionView.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//

// BoatSelectionView.swift
import SwiftUI

struct BoatSelectionView: View {
    @State private var boats: [BoatInfo] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var username: String
    var apiKey: String

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                Text("Loading boats...")
                    .font(.custom("BebasNeue", size: 24))
                    .foregroundColor(.white)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.custom("BebasNeue", size: 18))
            } else {
                List(boats) { boat in
                    NavigationLink(destination: BoatInfoView(boat: boat)) {
                        Text(boat.boatname ?? "Unknown")
                            .font(.custom("BebasNeue", size: 20))
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.black)
                }
                .background(Color.black)
                .scrollContentBackground(.hidden)
                .navigationTitle(Text("Your Boats")
                                    .font(.custom("BebasNeue", size: 30))
                                    .foregroundColor(.white))
            }
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear(perform: loadBoats)
    }

    private func loadBoats() {
        APIService.fetchAllBoats(username: username, apiKey: apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedBoats):
                    boats = fetchedBoats
                    isLoading = false
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
