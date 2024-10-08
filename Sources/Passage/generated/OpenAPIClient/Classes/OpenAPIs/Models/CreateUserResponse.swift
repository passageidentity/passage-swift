//
// CreateUserResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct CreateUserResponse: Codable, JSONEncodable, Hashable {

    public var user: User

    public init(user: User) {
        self.user = user
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case user
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
    }
}

