//
//  MockRequest.swift
//  GoogleSignInSwift_Tests
//
//  Created by Josh Kowarsky on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift

enum MockRequest: GoogleSignInRequest {
    case fake
    
    var baseURLString: String {
        return ""
    }

    var method: GoogleSignIn.HTTPMethod {
        return .get
    }

    var path: String {
        return ""
    }

    var parameters: GoogleSignIn.Parameters {
        return [:]
    }

    var headers: GoogleSignIn.HTTPHeaders {
        return [:]
    }

    func asURL() throws -> URL {
        return URL(string: "")!
    }

    func asURLRequest() throws -> URLRequest {
        let url = try asURL()
        return URLRequest(url: url)
    }
}
