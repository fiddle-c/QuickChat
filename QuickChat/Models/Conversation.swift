//
//  Conversation.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import Foundation

struct Conversation: Identifiable, Codable {
    let id = UUID()
    let clientName: String
    let lastMessageAt: Date
    let createdAt: Date
    let messageCount: String
    
    enum CodingKeys: String, CodingKey {
        case clientName = "client_name"
        case lastMessageAt = "last_message_at"
        case createdAt = "created_at"
        case messageCount = "message_count"
    }
    
    var timeAgo: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: lastMessageAt, to: now)
        
        if let minutes = components.minute, minutes < 60 {
            return minutes < 1 ? "Just now" : "\(minutes)m ago"
        } else if let hours = components.hour, hours < 24 {
            return "\(hours)h ago"
        } else if let days = components.day {
            return "\(days)d ago"
        }
        
        return lastMessageAt.formatted(date: .abbreviated, time: .omitted)
    }
}
