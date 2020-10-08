//
//  URLOpener.swift
//  GoogleSignInSwift
//
//  Created by Josh Kowarsky on 10/7/20.
//

public protocol GoogleSignInURLOpener {
    func open(url: URL)
}

public extension GoogleSignIn {
    struct URLOpener: GoogleSignInURLOpener {
        public init() { }

        public func open(url: URL) {
            if #available(iOS 10.0, *) {
                UIApplication
                    .shared
                    .open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
