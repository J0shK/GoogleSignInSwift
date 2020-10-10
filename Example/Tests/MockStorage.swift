//
//  MockStorage.swift
//  GoogleSignInSwift_Tests
//
//  Created by Josh Kowarsky on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift

class MockStorage: GoogleSignInStorage {
    var auth: GoogleSignIn.Auth?
    var user: GoogleSignIn.User?
    var cacheCleared = false
    func get() -> GoogleSignIn.Auth? {
        return auth
    }

    func get() -> GoogleSignIn.User? {
        return user
    }

    func set(auth: GoogleSignIn.Auth?) {
        self.auth = auth
    }

    func set(user: GoogleSignIn.User?) {
        self.user = user
    }

    func clear() -> Bool {
        cacheCleared = true
        return true
    }
}
