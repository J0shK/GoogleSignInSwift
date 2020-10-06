//
//  Auth.swift
//  GoogleSignIn-Swift
//
//  Created by Josh Kowarsky on 10/5/20.
//

public extension GoogleSignIn {
    struct Auth: Codable {
        public enum AuthType: String, Codable {
            case Bearer
        }
        public let accessToken: String
        public let expiresAt: Date
        public let refreshToken: String?
        public let scope: String
        public let tokenType: AuthType
        public let idToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresAt = "expires_in"
            case refreshToken = "refresh_token"
            case scope
            case tokenType = "token_type"
            case idToken = "id_token"
        }

        static func dateDecodingStrategy(decoder: Decoder) throws -> Date {
            let container = try decoder.singleValueContainer()
            let expiresSeconds = try container.decode(Int.self)
            return Date().addingTimeInterval(TimeInterval(expiresSeconds))
        }

        static func +(lhs: Self, rhs: Self) -> Self {
            let latest = lhs.expiresAt > rhs.expiresAt ? lhs : rhs
            let older = lhs.expiresAt < rhs.expiresAt ? lhs : rhs
            if latest.refreshToken == nil {
                return Auth(
                    accessToken: latest.accessToken,
                    expiresAt: latest.expiresAt,
                    refreshToken: older.refreshToken,
                    scope: latest.scope,
                    tokenType: latest.tokenType,
                    idToken: latest.idToken
                )
            } else {
                return latest
            }
        }
    }
}
