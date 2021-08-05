//
//  MyGamesNetworkManager.swift
//  Fox19
//
//  Created by Артём Скрипкин on 25.11.2020.
//

import Foundation
class MyGamesNetworkManager {
    private let mainHostPath = "http://213.159.209.245"
    private let hostPath = "http://213.159.209.245/api"
    private let game = "/game"
    private let gamemember = "/gamemember"
    private var headerForJson = ["Content-Type":"application/json"]
    
    private let user = "/user"
    
    private enum httpMethod: String {
        case POST
        case GET
        case PUT
        case DELETE
    }
    
    private enum Errors: Error {
        case body
        case response
        case request
        case data
        case parse
        case result
        case gettingUser
        case json
        case statusCode(Int)
    }
    
    static var shared = MyGamesNetworkManager()
    private init() {}
    
    //MARK: - Generate request
    private func generateRequestWithTwoHeaders(for action: String, method: String, body: Data?, token: String?) -> URLRequest? {
        guard let baseUrl = URL(string: hostPath) else { return nil }
        let url = baseUrl.appendingPathComponent(action)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("Application/json", forHTTPHeaderField: "Accept")
        }
        if let body = body {
            request.httpBody = body
        }
        return request
    }
    
    public func deleteGame(gameId: Int, token: String, completion: @escaping (Result<Game, Error>) -> Void) {
        guard let request = generateRequestWithTwoHeaders(for: "\(game)/\(gameId)", method: httpMethod.DELETE.rawValue, body: nil, token: token) else { completion(.failure(Errors.request)); return }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                guard response.statusCode == 200 else { completion(.failure(Errors.statusCode(response.statusCode))); print(response); return }
                guard let data = data else { completion(.failure(Errors.data)); return }
                guard let parsedGame = try? JSONDecoder().decode(Game.self, from: data) else { completion(.failure(Errors.parse)); return }
                completion(.success(parsedGame))
            } else {
                completion(.failure(Errors.response))
            }
        }.resume()
    }
}
