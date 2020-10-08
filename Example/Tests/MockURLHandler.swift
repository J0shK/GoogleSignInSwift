//
//  MockURLOpener.swift
//  GoogleSignInSwift_Tests
//
//  Created by Josh Kowarsky on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift

class MockURLOpener: GoogleSignInURLOpener {
    var openedURLs = [URL]()
    var handledURLs = [URL]()
    var code = ""
    func open(url: URL) {
        openedURLs.append(url)
    }

    func handleURL(_ url: URL, redirectURI: String, authenticate: (String) -> Void) -> Bool {
        handledURLs.append(url)
        authenticate(code)
        return true
    }
}
