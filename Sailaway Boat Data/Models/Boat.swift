//
//  Boat.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//


import Foundation

struct Boat: Identifiable, Codable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "ubtnr" // Mapujemy "ubtnr" na "id"
        case name = "boatname"
    }
}

struct BoatInfo: Codable, Identifiable {
    let ubtnr: String? // ID jachtu
    let boatname: String?
    let longitude: Double?
    let latitude: Double?
    let sog: Double? // Speed Over Ground
    let cog: Double? // Course Over Ground
    let voyage: String?
    let awa: Double? // Apparent Wind Angle
    let tws: Double? // True Wind Speed
    let heeldegrees: Double? // Kąt przechyłu łodzi
    let sails: [Sail]?

    // Implementacja protokołu Identifiable
    var id: String {
        ubtnr ?? UUID().uuidString // Użyj `ubtnr` jako identyfikatora lub wygeneruj UUID
    }

    struct Sail: Codable {
        let sail: String? // Nazwa żagla
        let furled: Int? // 0: rozwinięty, 1: zwinięty
        let sheet: Int? // Pozycja szotów lub kontrola
        let reef1: Int? // 1: pierwszy ref założony
        let reef2: Int? // 1: drugi ref założony
        let reef3: Int? // 1: trzeci ref założony

        // Sprawdza, czy żagiel jest w użyciu
        var isInUse: Bool {
            furled == 0
        }

        // Sprawdza, czy na grocie założony jest ref
        var activeReef: String? {
            if reef1 == 1 { return "Reef 1" }
            if reef2 == 1 { return "Reef 2" }
            if reef3 == 1 { return "Reef 3" }
            return nil
        }
    }

    // Funkcja zwracająca listę aktywnych żagli
    func activeSails() -> [String] {
        sails?.filter { $0.isInUse }.compactMap { $0.sail } ?? []
    }

    // Funkcja zwracająca żagle założone na sztagu
    // Funkcja zwracająca żagle założone na sztagu
    func forestaySails() -> [String] {
        sails?.filter { $0.isInUse }.compactMap { sail in
            guard let name = sail.sail?.lowercased() else { return nil }
            if name.contains("nr.1") || name.contains("jib 1") || name.contains("j1") { return "J1" }
            if name.contains("nr.2") || name.contains("jib 2") || name.contains("j2") { return "J2" }
            if name.contains("nr.3") || name.contains("jib 3") || name.contains("j3") { return "J3" }
            if name.contains("nr.4") || name.contains("jib 4") || name.contains("j4") { return "J4" }
            if name.contains("storm jib") || name.contains("sj") { return "SJ" }
            if name.contains("code 0") { return "Code 0" }
            if name.contains("gennaker") { return "Gennaker" }
            return nil // Ignorujemy inne żagle
        } ?? []
    }


    // Funkcja sprawdzająca refy na grocie
    func mainsailReef() -> String? {
        sails?.first { $0.sail?.lowercased() == "mainsail" }?.activeReef
    }

    // Funkcja zwracająca kafelek z informacją o aktualnym żaglu na sztagu i refach na grocie
    func displayCurrentSailsInfo() -> String {
        let forestay = forestaySails().joined(separator: " + ")
        let reef = mainsailReef()
        var info = "Sails in use:\n"

        if !forestay.isEmpty {
            info += "Forestay: \(forestay)\n"
        } else {
            info += "Forestay: None\n"
        }

        if let reef = reef {
            info += "Mainsail: \(reef)\n"
        } else {
            info += "Mainsail: Full sail\n"
        }

        return info
    }
}
