//
//  GoogleSignIn.swift
//  GoogleSignIn-Swift
//
//  Created by Josh Kowarsky on 10/5/20.
//

import Foundation

public protocol GoogleSignInDelegate: AnyObject {
    func googleSignIn(didSignIn auth: GoogleSignIn.Auth, user: GoogleSignIn.User)
    func googleSignIn(signInDidError error: Error)
}

public extension GoogleSignInDelegate {
    func googleSignIn(signInDidError error: Error) {}
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
    public var scopes = ["profile", "email"]

    public var auth: Auth?
    public var user: User?

    public var redirectURI: String {
        return clientId.components(separatedBy: ".").reversed().joined(separator: ".")
    }
    public var isSignedIn: Bool {
        return auth != nil
    }

    private let api = API()

    public init(storage: GoogleSignInStorage = DefaultStorage()) {
        self.storage = storage
        auth = storage.get()
        user = storage.get()
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
            delegate?.googleSignIn(signInDidError: Error.noClientId)
            return
        }
        guard !scopes.isEmpty else {
            delegate?.googleSignIn(signInDidError: Error.noScope)
            return
        }
        do {
            let url = try Request.auth.asURL()
            openURL(url)
        } catch {
            delegate?.googleSignIn(signInDidError: error)
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
        api.request(Request.refreshToken) { [weak self] result in
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

    private func openURL(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication
                .shared
                .open(url, options: [:])
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    public func getProfile(completion: @escaping ProfileBlock) {
        guard auth?.accessToken != nil else {
            completion(nil, Error.noAccessToken)
            return
        }
        api.request(Request.getProfile) { [weak self] result in
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

    private func authenticate(with code: String) {
        guard !clientId.isEmpty else {
            delegate?.googleSignIn(signInDidError: Error.noClientId)
            return
        }
        api.request(Request.token(code: code)) { [weak self] completion in
            switch completion {
            case .error(let error):
                self?.delegate?.googleSignIn(signInDidError: error)
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(Auth.dateDecodingStrategy)
                guard let auth = try? decoder.decode(Auth.self, from: data) else {
                    self?.delegate?.googleSignIn(signInDidError: Error.jsonDecodeError)
                    return
                }
                self?.auth = auth
                self?.storage.set(auth: auth)
                self?.getProfile { user, error in
                    if let error = error {
                        self?.delegate?.googleSignIn(signInDidError: error)
                        return
                    }
                    guard let user = user else {
                        self?.delegate?.googleSignIn(signInDidError: Error.noUser)
                        return
                    }
                    self?.delegate?.googleSignIn(didSignIn: auth, user: user)
                }
            }
        }
    }
}
