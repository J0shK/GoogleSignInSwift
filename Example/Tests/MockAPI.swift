//
//  MockAPI.swift
//  GoogleSignInSwift_Tests
//
//  Created by Josh Kowarsky on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift

class MockAPI: GoogleSignInAPI {
    var requests = [GoogleSignInRequest]()
    func request(_ request: GoogleSignInRequest, completion: @escaping CompletionBlock) {
        requests.append(request)
        completion(.success(data: Data()))
    }

    func performedRequest(_ request: GoogleSignInRequest) -> Bool {
        return requests.contains { performedRequest -> Bool in
            guard let performedURLRequest = try? performedRequest.asURLRequest(), let urlRequest = try? request.asURLRequest() else { return false }
            return performedURLRequest == urlRequest
        }
    }
}
