//
//  GoogleSignIn.swift
//  GoogleSignIn-Swift
//
//  Created by Josh Kowarsky on 10/5/20.
//

import Foundation

public protocol GoogleSignInDelegate: AnyObject {
    func googleSignIn(didSignIn auth: GoogleSignIn.Auth?, user: GoogleSignIn.User?, error: Error?)
}

public class GoogleSignIn {
    public enum Error: Swift.Error {
        case noClientId
        case noScope
        case noRefreshToken
        case noAccessToken
        case notSignedIn
        case jsonDecodeError
        case noUser
    }
    public typealias RefreshBlock = (Auth?, Swift.Error?) -> Void
    public typealias RefreshingTokenBlock = (String?, Swift.Error?) -> Void
    public typealias ProfileBlock = (User?, Swift.Error?) -> Void

    public static let shared = GoogleSignIn()

    public weak var delegate: GoogleSignInDelegate?
    public var storage: GoogleSignInStorage {
        didSet {
            auth = storage.get()
            user = storage.get()
        }
    }

    public var clientId: String = ""
    public var scopes: [String] {
        var set = Set(privateScopes)
        if profile {
            set.insert("profile")
        }
        if email {
            set.insert("email")
        }
        return Array(set)
    }
    private var privateScopes = Set<String>()
    public var profile = true
    public var email = false

    public var auth: Auth?
    public var user: User?

    public var redirectURI: String {
        return clientId.components(separatedBy: ".").reversed().joined(separator: ".")
    }
    public var isSignedIn: Bool {
        return auth != nil
    }

    private var api: GoogleSignInAPI
    private var urlOpener: GoogleSignInURLOpener

    public init(api: GoogleSignInAPI = API(),
                storage: GoogleSignInStorage = DefaultStorage(),
                urlOpener: GoogleSignInURLOpener = URLOpener()) {
        self.api = api
        self.urlOpener = urlOpener
        self.storage = storage
        auth = storage.get()
        user = storage.get()
    }

    public func addScope(_ scope: String) {
        privateScopes.insert(scope)
    }

    public func addScopes(_ scopes: [String]) {
        for scope in scopes {
            addScope(scope)
        }
    }

    public func removeScope(_ scope: String) {
        privateScopes.remove(scope)
    }

    public func removeScopes(_ scopes: [String]) {
        for scope in scopes {
            removeScope(scope)
        }
    }

    public func handleURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), components.scheme == redirectURI else {
            return false
        }
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return false
        }
        authenticate(with: code)
        return true
    }

    public func signIn() {
        guard !clientId.isEmpty else {
            delegate?.googleSignIn(didSignIn: nil, user: nil, error: Error.noClientId)
            return
        }
        guard !scopes.isEmpty else {
            delegate?.googleSignIn(didSignIn: nil, user: nil, error: Error.noScope)
            return
        }
        do {
            let url = try Request.auth(clientId: clientId, scopes: scopes, redirectURI: redirectURI).asURL()
            urlOpener.open(url: url)
        } catch {
            delegate?.googleSignIn(didSignIn: nil, user: nil, error: error)
        }
    }

    @discardableResult
    public func signOut() -> Bool {
        auth = nil
        return storage.clear()
    }

    public func refreshToken(completion: RefreshBlock? = nil) {
        guard !clientId.isEmpty else {
            completion?(nil, Error.noClientId)
            return
        }
        guard let auth = auth, auth.refreshToken != nil else {
            completion?(nil, Error.noRefreshToken)
            return
        }
        api.request(Request.refreshToken(clientId: clientId, refreshToken: auth.refreshToken ?? "")) { [weak self] result in
            switch result {
            case .error(let error):
                completion?(nil, error)
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(Auth.dateDecodingStrategy)
                guard let auth = try? decoder.decode(Auth.self, from: data) else {
                    completion?(nil, Error.jsonDecodeError)
                    return
                }
                if let oldAuth = self?.auth {
                    self?.auth = oldAuth + auth
                } else {
                    self?.auth = auth
                }
                
                self?.storage.set(auth: auth)
                completion?(self?.auth, nil)
            }
        }
    }

    public func refreshingAccessToken(completion: @escaping RefreshingTokenBlock) {
        guard let auth = auth else {
            completion(nil, Error.notSignedIn)
            return
        }
        guard Date().timeIntervalSince(auth.expiresAt) > 0 else {
            completion(auth.accessToken, nil)
            return
        }

        refreshToken { auth, error in
            completion(auth?.accessToken, error)
        }
    }

    private func authenticate(with code: String) {
        guard !clientId.isEmpty else {
            delegate?.googleSignIn(didSignIn: nil, user: nil, error: Error.noClientId)
            return
        }
        api.request(Request.token(code: code, clientId: clientId, redirectURI: redirectURI)) { [weak self] completion in
            switch completion {
            case .error(let error):
                self?.delegate?.googleSignIn(didSignIn: nil, user: nil, error: error)
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(Auth.dateDecodingStrategy)
                guard let auth = try? decoder.decode(Auth.self, from: data) else {
                    self?.delegate?.googleSignIn(didSignIn: nil, user: nil, error: Error.jsonDecodeError)
                    return
                }
                self?.auth = auth
                self?.storage.set(auth: auth)
                self?.getProfile { user, error in
                    if let error = error {
                        self?.delegate?.googleSignIn(didSignIn: auth, user: nil, error: error)
                        return
                    }
                    guard let user = user else {
                        self?.delegate?.googleSignIn(didSignIn: auth, user: nil, error: Error.noUser)
                        return
                    }
                    self?.delegate?.googleSignIn(didSignIn: auth, user: user, error: nil)
                }
            }
        }
    }
    
    public func getProfile(completion: @escaping ProfileBlock) {
        guard let accessToken = auth?.accessToken else {
            completion(nil, Error.noAccessToken)
            return
        }
        guard profile || email else {
            completion(nil, Error.noScope)
            return
        }
        api.request(Request.getProfile(accessToken: accessToken)) { [weak self] result in
            switch result {
            case .error(let error):
                completion(nil, error)
            case .success(let data):
                guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                    completion(nil, Error.jsonDecodeError)
                    return
                }
                self?.user = user
                self?.storage.set(user: user)
                completion(user, nil)
            }
        }
    }
}
