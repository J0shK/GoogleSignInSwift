//
//  Request.swift
//  GoogleSignIn-Swift
//
//  Created by Josh Kowarsky on 10/5/20.
//

enum HTTPMethod: String {
    case get
    case post
}

typealias Parameters = [String: Any]
typealias HTTPHeaders = [String: String]

enum Request {
    enum Error: Swift.Error {
        case createURLError
    }
    
    var baseURLString: String {
        switch self {
        case .auth:
            return "https://accounts.google.com/o/oauth2/v2"
        case .token, .refreshToken:
            return "https://oauth2.googleapis.com"
        case .getProfile:
            return "https://www.googleapis.com/oauth2/v2"
        }
    }

    case auth
    case token(code: String)
    case refreshToken
    case getProfile

    var method: HTTPMethod {
        switch self {
        case .auth, .getProfile:
            return .get
        case .token, .refreshToken:
            return .post
        }
    }

    var path: String {
        switch self {
        case .auth:
            return "auth"
        case .token, .refreshToken:
            return "token"
        case .getProfile:
            return "userinfo"
        }
    }

    var parameters: Parameters {
        switch self {
        case .auth:
            return [
                "client_id": GoogleSignIn.shared.clientId,
                "scope": GoogleSignIn.shared.scopes.joined(separator: " "),
                "response_type": "code",
                "redirect_uri": "\(GoogleSignIn.shared.redirectURI):code"
            ]
        case .token(let code):
            return [
                "code": code,
                "client_id": GoogleSignIn.shared.clientId,
                "grant_type": "authorization_code",
                "redirect_uri": "\(GoogleSignIn.shared.redirectURI):code"
            ]
        case .refreshToken:
            return [
                "client_id": GoogleSignIn.shared.clientId,
                "refresh_token": GoogleSignIn.shared.auth?.refreshToken ?? "",
                "grant_type": "refresh_token"
            ]
        case .getProfile:
            return [
                "access_token": GoogleSignIn.shared.auth?.accessToken ?? "",
                "alt": "json"
            ]
        }
    }

    var headers: HTTPHeaders {
        return [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    }

    func asURL() throws -> URL {
        guard var components = URLComponents(string: baseURLString) else {
            throw Error.createURLError
        }
        components.path = "\(components.path)/\(path)"
        if method == .get {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
        }
        guard let url = components.url else {
            throw Error.createURLError
        }

        return url
    }

    func asURLRequest() throws -> URLRequest {
        let url = try asURL()
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        if method == .post {
            request.httpBody = parameters.percentEncoded()
        }
        request.httpMethod = method.rawValue.uppercased()
        return request
    }
}

private extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
