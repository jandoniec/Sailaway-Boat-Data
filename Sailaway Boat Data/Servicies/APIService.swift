//
//  APIService.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//

//
//  APIService.swift
//  Sailaway Boat Data
//
//  Created by Jan Doniec on 19/01/2025.
//
import Foundation

struct APIService {
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // Limit czasu dla żądań
        config.timeoutIntervalForResource = 60 // Limit czasu dla zasobów
        return URLSession(configuration: config)
    }()
    
    static func testLogin(username: String, apiKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Ręczne tworzenie URL z wymuszoną kolejnością parametrów
        let urlString = "http://srv.sailaway.world/cgi-bin/sailaway/APIBoatInfo.pl?usrnr=\(username.trimmingCharacters(in: .whitespacesAndNewlines))&key=\(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))"
        
        guard let url = URL(string: urlString) else {
            print("Error generating URL")
            completion(.failure(NSError(domain: "InvalidURLError", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        // Logowanie URL
        print("Generated URL: \(url.absoluteString)")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received.")
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: nil)))
                return
            }
            
            if let responseText = String(data: data, encoding: .utf8) {
                print("Raw API response: \(responseText)")
            }
            
            if let responseText = String(data: data, encoding: .utf8), responseText.contains("Error") {
                completion(.failure(NSError(domain: "InvalidCredentials", code: 401, userInfo: nil)))
            } else {
                completion(.success(()))
            }
        }.resume()
    }
    
    static func fetchBoats(username: String, apiKey: String, completion: @escaping (Result<[Boat], Error>) -> Void) {
        let urlString = "http://srv.sailaway.world/cgi-bin/sailaway/APIBoatInfo.pl?usrnr=\(username)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        let request = URLRequest(url: url)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let decodedData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = decodedData["error"] as? String {
                    completion(.failure(NSError(domain: "APIError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    let boats = try JSONDecoder().decode([Boat].self, from: data)
                    completion(.success(boats))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    static func fetchAllBoats(username: String, apiKey: String, completion: @escaping (Result<[BoatInfo], Error>) -> Void) {
        let urlString = "http://srv.sailaway.world/cgi-bin/sailaway/APIBoatInfo.pl?usrnr=\(username)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([BoatInfo].self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(APIError.decodingError))
            }
        }.resume()
    }

    static func fetchBoatInfo(username: String, apiKey: String, boatId: String, completion: @escaping (Result<BoatInfo, Error>) -> Void) {
        let urlString = "https://api.sailaway.com/boatinfo?username=\(username)&apikey=\(apiKey)&ubtnr=\(boatId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                // Decode JSON into BoatInfo
                let boatInfo = try JSONDecoder().decode(BoatInfo.self, from: data)
                completion(.success(boatInfo))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case boatNotFound

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .noData:
                return "No data received from the server."
            case .decodingError:
                return "Failed to decode the data."
            case .boatNotFound:
                return "Boat not found in the response."
            }
        }
    }

}


