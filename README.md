# GoogleSignInSwift

[![CI Status](https://img.shields.io/travis/J0shK/GoogleSignInSwift.svg?style=flat)](https://travis-ci.org/J0shK/GoogleSignInSwift)
[![Version](https://img.shields.io/cocoapods/v/GoogleSignInSwift.svg?style=flat)](https://cocoapods.org/pods/GoogleSignInSwift)
[![License](https://img.shields.io/cocoapods/l/GoogleSignInSwift.svg?style=flat)](https://cocoapods.org/pods/GoogleSignInSwift)
[![Platform](https://img.shields.io/cocoapods/p/GoogleSignInSwift.svg?style=flat)](https://cocoapods.org/pods/GoogleSignInSwift)

`GoogleSignInSwift` is used to obtain a users Google authentication credentials and/or their profile information. `GoogleSignInSwift` is written 100% in Swift and requires **ZERO** dependencies. It uses fast-app-switching with `Safari` to securely and conveniently sign the user in.

## Installation

`GoogleSignInSwift` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GoogleSignInSwift'
```
# Usage

### Setup
Supply `GoogleSignIn` with your Google API `Client ID` and any Google API scope
```swift
GoogleSignIn.shared.clientId = "<Google API Client ID>"
GoogleSignIn.shared.addScope("<Google API Scope>")
```

#### Get user email
```swift
GoogleSignIn.shared.email = true
```
You can also disable `profile` (default `true`)
### Sign in
```swift
GoogleSignIn.shared.delegate = self
GoogleSignIn.shared.signIn()
```
Listen for completion by implementing
```swift
func googleSignIn(didSignIn auth: GoogleSignIn.Auth?, user: GoogleSignIn.User?, error: Error?) { }
```
### Sign out
```swift
GoogleSignIn.shared.signOut()
```
### Auth status
```swift
GoogleSignIn.shared.isSignedIn
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Josh Kowarsky, josh.kowarsky@gmail.com

## License

GoogleSignInSwift is available under the MIT license. See the LICENSE file for more info.
