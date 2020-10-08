//
//  MockURLOpener.swift
//  GoogleSignInSwift_Tests
//
//  Created by Josh Kowarsky on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift

class MockURLOpener: GoogleSignInURLOpener {
    var lastURL: URL?
    func open(url: URL) {
        lastURL = url
    }
}
