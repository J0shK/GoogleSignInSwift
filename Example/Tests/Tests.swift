// https://github.com/Quick/Quick

import Quick
import Nimble
import GoogleSignInSwift

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        let mockApi = MockAPI()
        let mockStorage = MockStorage()
        let mockGoogleSignIn = GoogleSignIn(api: mockApi, storage: mockStorage)
        mockGoogleSignIn.clientId = "this-is-a-client-id"
        mockGoogleSignIn.addScope("this-is-a-scope")

        context("Sign in") {
            describe("process") {
                beforeEach {
                    mockGoogleSignIn.signIn()
                }

                let code = "1234"

                it("opens the correct URL") {
                    let signInURL = try! mockGoogleSignIn.signInURL()
                    let components = URLComponents(url: signInURL, resolvingAgainstBaseURL: true)

                    expect(components?.host).to(equal("accounts.google.com"))
                    expect(components?.path).to(equal("/o/oauth2/v2/auth"))
                    var clientId: String?
                    var scopes: String?
                    if let queryItems = components?.queryItems {
                        for queryItem in queryItems {
                            if queryItem.name == "client_id" {
                                clientId = queryItem.value
                            }
                            if queryItem.name == "scope" {
                                scopes = queryItem.value
                            }
                        }
                    }
                    expect(clientId).to(equal(mockGoogleSignIn.clientId))
                    let scopeComponents = scopes?.components(separatedBy: " ")
                    expect(scopeComponents).to(contain("profile"))
                    expect(scopeComponents).to(contain("this-is-a-scope"))
                }

                it("handles incoming URL") {
                    let returnURL = URL(string: "\(mockGoogleSignIn.redirectURI)://?code=\(code)")!
                    let handled = mockGoogleSignIn.handleURL(returnURL)
                    expect(handled).to(beTrue())
                }

                it("authorizes") {
                    _ = mockGoogleSignIn.handleURL(URL(string: "\(mockGoogleSignIn.redirectURI)://?code=\(code)")!)
                    let request = try! mockApi.requests.last!.asURLRequest()
                    expect(request.url?.absoluteString).toEventually(equal("https://oauth2.googleapis.com/token"))
                    let bodyString = String(data: request.httpBody!, encoding: .utf8)!
                    let bodyComponents = bodyString.components(separatedBy: "&")
                    var codeCheck: String?
                    var clientId: String?
                    for component in bodyComponents {
                        let item = component.components(separatedBy: "=")
                        if item.first == "code" {
                            codeCheck = item.last
                        }
                        if item.first == "client_id" {
                            clientId = item.last
                        }
                    }
                    expect(codeCheck).to(equal(code))
                    expect(clientId).to(equal(mockGoogleSignIn.clientId))
                }
            }
        }

        context("Sign Out") {
            describe("process") {
                beforeEach {
                    mockGoogleSignIn.signOut()
                }

                it("clears auth") {
                    expect(mockGoogleSignIn.auth).to(beNil())
                }

                it("clears cache") {
                    expect(mockStorage.cacheCleared).to(beTrue())
                }
            }
        }

        context("Token Refresh") {
            beforeEach {
                mockGoogleSignIn.auth = GoogleSignIn.Auth(
                    accessToken: "this-is-an-access-token",
                    expiresAt: Date(),
                    refreshToken: "this-is-a-refresh-token",
                    scope: "this-is-scope",
                    tokenType: .Bearer,
                    idToken: "this-is-id-token"
                )
            }

            describe("manual refresh") {
                it("builds valid request") {
                    mockGoogleSignIn.refreshToken()
                    let request = try! mockApi.requests.last!.asURLRequest()
                    expect(request.url?.absoluteString).toEventually(equal("https://oauth2.googleapis.com/token"))
                    let bodyString = String(data: request.httpBody!, encoding: .utf8)!
                    let bodyComponents = bodyString.components(separatedBy: "&")
                    var refreshToken: String?
                    var clientId: String?
                    for component in bodyComponents {
                        let item = component.components(separatedBy: "=")
                        if item.first == "refresh_token" {
                            refreshToken = item.last
                        }
                        if item.first == "client_id" {
                            clientId = item.last
                        }
                    }
                    expect(refreshToken).to(equal(mockGoogleSignIn.auth?.refreshToken))
                    expect(clientId).to(equal(mockGoogleSignIn.clientId))
                }
            }

            describe("refreshing access token") {
                it("builds valid request") {
                    mockGoogleSignIn.refreshingAccessToken { _, _ in }
                    let request = try! mockApi.requests.last!.asURLRequest()
                    expect(request.url?.absoluteString).toEventually(equal("https://oauth2.googleapis.com/token"))
                    let bodyString = String(data: request.httpBody!, encoding: .utf8)!
                    let bodyComponents = bodyString.components(separatedBy: "&")
                    var refreshToken: String?
                    var clientId: String?
                    for component in bodyComponents {
                        let item = component.components(separatedBy: "=")
                        if item.first == "refresh_token" {
                            refreshToken = item.last
                        }
                        if item.first == "client_id" {
                            clientId = item.last
                        }
                    }
                    expect(refreshToken).to(equal(mockGoogleSignIn.auth?.refreshToken))
                    expect(clientId).to(equal(mockGoogleSignIn.clientId))
                }
            }

            describe("refresh tokens") {
                it("can be added together") {
                    let auth1 = GoogleSignIn.Auth(accessToken: "access1", expiresAt: Date(), refreshToken: "refresh1", scope: "scope1", tokenType: .Bearer, idToken: "id1")
                    let auth2 = GoogleSignIn.Auth(accessToken: "access2", expiresAt: Date().addingTimeInterval(100), refreshToken: nil, scope: "scope2", tokenType: .Bearer, idToken: "id2")

                    let auth3: GoogleSignIn.Auth = auth1 + auth2
                    expect(auth3.accessToken).to(equal(auth2.accessToken))
                    expect(auth3.refreshToken).to(equal(auth1.refreshToken))
                }
            }
        }
    }
}
