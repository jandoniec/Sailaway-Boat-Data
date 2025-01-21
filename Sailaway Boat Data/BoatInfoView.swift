//
//  BoatInfoView.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//

//
//  BoatInfoView.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//


import SwiftUI

struct BoatInfoView: View {
    var boat: BoatInfo

    var body: some View {
        VStack(spacing: 20) {
            // Nazwa łodzi
            Text(boat.boatname ?? "Unknown Boat")
                .font(.custom("BebasNeue", size: 40))
                .foregroundColor(.white)
                .padding(.top, 20)

            // Voyage
            Text(boat.voyage ?? "No Voyage Data")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.gray)

            Divider()
                .background(Color.gray)

            // Latitude i Longitude w jednym wierszu
            HStack(spacing: 20) {
                VStack {
                    Text("Latitude:")
                        .font(.custom("BebasNeue", size: 18))
                        .foregroundColor(.white)
                    Text(formatToDMSWithDirection(boat.latitude, isLongitude: false))
                        .font(.custom("LCDMono2", size: 18))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                VStack {
                    Text("Longitude:")
                        .font(.custom("BebasNeue", size: 18))
                        .foregroundColor(.white)
                    Text(formatToDMSWithDirection(boat.longitude, isLongitude: true))
                        .font(.custom("LCDMono2", size: 18))
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            // Rząd 2: AWA, TWS, Heel
            HStack(spacing: 10) {
                dataBlock(title: "AWA", value: formatToDecimal(boat.awa, decimals: 1) + "°", color: .purple)
                dataBlock(title: "TWS", value: formatToDecimal(boat.tws, decimals: 1) + " knots", color: .orange, useHelveticaForKnots: true)
                dataBlock(title: "Heel", value: formatToDecimal(boat.heeldegrees, decimals: 2) + "°", color: .red)
            }

            // Rząd 3: SOG, COG
            HStack(spacing: 10) {
                dataBlock(title: "SOG", value: formatToDecimal(boat.sog, decimals: 2) + " knots", color: .cyan, useHelveticaForKnots: true)
                dataBlock(title: "COG", value: formatToDecimal(boat.cog, decimals: 0) + "°", color: .yellow)
            }

            // Sekcja z informacjami o żaglach
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Sails")
                    .font(.headline)
                    .foregroundColor(.white)

                let forestaySails = boat.forestaySails().map { sail in
                    if sail.lowercased().contains("nr.1") || sail.lowercased().contains("jib 1") { return "J1" }
                    if sail.lowercased().contains("nr.2") || sail.lowercased().contains("jib 2") { return "J2" }
                    if sail.lowercased().contains("nr.3") || sail.lowercased().contains("jib 3") { return "J3" }
                    if sail.lowercased().contains("nr.4") || sail.lowercased().contains("jib 4") { return "J4" }
                    if sail.lowercased().contains("storm jib") { return "SJ" }
                    if sail.lowercased().contains("code 0") { return "Code 0" }
                    if sail.lowercased().contains("gennaker") { return "Gennaker" }
                    return sail
                }

                if !forestaySails.isEmpty {
                    HStack {
                        Text("Forestay:")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(forestaySails.joined(separator: " + "))
                            .foregroundColor(.blue)
                    }
                } else {
                    HStack {
                        Text("Forestay:")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("None")
                            .foregroundColor(.gray)
                    }
                }

                if let mainsailReef = boat.mainsailReef() {
                    HStack {
                        Text("Mainsail:")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(mainsailReef)
                            .foregroundColor(.orange)
                    }
                } else {
                    HStack {
                        Text("Mainsail:")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Full sail")
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private func formatToDMSWithDirection(_ value: Double?, isLongitude: Bool) -> String {
        guard let value = value else { return "N/A" }

        let degrees = Int(value)
        let decimalPart = abs(value) - Double(degrees)
        let minutes = Int(decimalPart * 60)
        let secondsDecimal = (decimalPart * 60) - Double(minutes)
        let seconds = Int(secondsDecimal * 60)

        let direction: String
        if isLongitude {
            direction = value >= 0 ? "E" : "W"
        } else {
            direction = value >= 0 ? "N" : "S"
        }

        return "\(abs(degrees))° \(minutes)' \(seconds)\" \(direction)"
    }

    @ViewBuilder
    private func dataBlock(title: String, value: String, color: Color, useHelveticaForKnots: Bool = false) -> some View {
        VStack {
            Text(title)
                .font(.custom("BebasNeue", size: 18))
                .foregroundColor(.white)

            if useHelveticaForKnots, value.contains("knots") {
                let parts = value.split(separator: " ")
                if let mainValue = parts.first, parts.count > 1 {
                    HStack(spacing: 2) {
                        Text(String(mainValue))
                            .font(.custom("LCDMono2", size: 24))
                            .foregroundColor(color)
                        Text("knots")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(color)
                    }
                }
            } else {
                Text(value)
                    .font(.custom("LCDMono2", size: 24))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    private func formatToDecimal(_ value: Double?, decimals: Int) -> String {
        guard let value = value else { return "N/A" }
        return String(format: "%.\(decimals)f", value)
    }
}
