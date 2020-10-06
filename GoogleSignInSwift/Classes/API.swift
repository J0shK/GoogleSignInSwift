//
//  API.swift
//  GoogleSignIn-Swift
//
//  Created by Josh Kowarsky on 10/5/20.
//

import Foundation

struct API {
    enum Error: Swift.Error {
        case networkError
        case noData
        case httpError(code: Int)
    }

    typealias CompletionBlock = (Result) -> Void

    enum Result {
        case success(data: Data)
        case error(error: Error)
    }

    func request(_ request: Request, completionBlock: @escaping CompletionBlock) {
        guard let urlRequest = try? request.asURLRequest() else { return }
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            if error != nil {
                completionBlock(.error(error: .networkError))
                return
            }

            guard let data = data else {
                completionBlock(.error(error: .noData))
                return
            }

            if let response = response as? HTTPURLResponse {
                guard (200 ... 299) ~= response.statusCode else {
                    completionBlock(.error(error: .httpError(code: response.statusCode)))
                    return
                }
            }

            completionBlock(.success(data: data))
        }

        task.resume()
    }
}
