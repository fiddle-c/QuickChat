//
//  Messages.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import Foundation
import SwiftUI

struct Message: Identifiable, Codable {
    let id: Int
    let clientName: String
    let message: String
    let sender: String
    let timestamp: Date
    
    init(sender: String) {
        id = Int.random(in: 1...1000)
        self.timestamp = Date()
        self.sender = sender
        self.clientName = "\(id)"
        self.message = sender
        
    }
    
    init(id:Int, clientName: String, message: String, sender: String, timestamp: Date) {
        self.id = id
        self.clientName = clientName
        self.message = message
        self.sender = sender
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientName
        case message
        case sender
        case timestamp = "createdAt"
    }
    
    var isAgent: Bool {
        sender == "agent"
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct ConversationHistoryResponse: Codable {
    let clientName: String
    let messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case clientName = "clientName"
        case messages = "messages"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.clientName = try container.decode(String.self, forKey: .clientName)
        self.messages = try container.decode([Message].self, forKey: .messages)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.clientName, forKey: .clientName)
        try container.encode(self.messages, forKey: .messages)
    }
        
    
}

struct ReceiveMessageData: Codable {
    let clientName: String
    let message: String
    let timestamp: Date
}
