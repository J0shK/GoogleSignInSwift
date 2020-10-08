//
//  MockStorage.swift
//  GoogleSignInSwift_Tests
//
//  Created by Josh Kowarsky on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift

class MockStorage: GoogleSignInStorage {
    var cacheCleared = false
    func get() -> GoogleSignIn.Auth? {
        return nil
    }

    func get() -> GoogleSignIn.User? {
        return nil
    }

    func set(auth: GoogleSignIn.Auth?) {
        //
    }

    func set(user: GoogleSignIn.User?) {
        //
    }

    func clear() -> Bool {
        cacheCleared = true
        return true
    }
}
