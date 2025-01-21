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

import SwiftUI

struct BoatSelectionView: View {
    @State private var boats: [BoatInfo] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var username: String
    var apiKey: String
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Text("Loading boats...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else {
                    List(boats) { boat in
                        NavigationLink(destination: BoatInfoView(boat: boat)) {
                            Text(boat.boatname ?? "Unknown")
                        }
                    }
                    .navigationTitle("Your Boats")
                }
            }
            .onAppear(perform: loadBoats)
        }
    }
    
    private func loadBoats() {
        APIService.fetchAllBoats(username: username, apiKey: apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedBoats):
                    self.boats = fetchedBoats
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
