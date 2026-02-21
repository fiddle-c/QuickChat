//
//  Agent.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import Foundation

struct Agent: Codable, Identifiable {
    let id = UUID()
    let username: String
    let email: String
    
    init() {
        self.username = self.id.uuidString
        self.email = self.id.uuidString + "@example.com"
    }
    
    enum CodingKeys: String, CodingKey {
        case username, email
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let agent: Agent
    let error: String?
}

struct AuthCheckResponse: Codable {
    let authenticated: Bool
    let agent: Agent?
}
