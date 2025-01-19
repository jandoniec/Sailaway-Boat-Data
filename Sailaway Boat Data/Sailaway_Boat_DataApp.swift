//
//  Sailaway_Boat_DataApp.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//

import SwiftUI

@main
struct Sailaway_Boat_DataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
