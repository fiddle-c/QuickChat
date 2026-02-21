//
//  HomeViewModel.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/9/26.
//

import Foundation
import Combine
@Observable
@MainActor
final class HomeViewModel: ObservableObject {
    var conversations: [Conversation] = []
    private var isConfigured = false
    func getConversations() {
     
    }
    func configureAndConnect() {
//        guard !isConfigured else { return }
//        isConfigured = true
//
//        // Configure with your server URL and headers if needed
//        let url = URL(string: "https://your-socket-server.example.com")!
//        SocketService.shared.configure(url: url, extraHeaders: [
//            
//            "create a": "key"
//            // "Authorization": "Bearer <token>"
//        ])
//
//        // Register listeners BEFORE connecting to avoid missing events
//        registerSocketListeners()
//
//        // Connect
//        SocketService.shared.connect(onConnect: { [weak self] in
//            Task { @MainActor in
//                // Optionally fetch initial conversations from REST or emit a "join" event
//                self?.loadInitialConversations()
//            }
//        })
    }

    func disconnect() {
//        SocketService.shared.disconnect()
    }

    private func registerSocketListeners() {
        // Example: incoming message event
//        SocketService.shared.on("message") { [weak self] data, _ in
//            guard let self else { return }
//            // Parse payload according to your backend schema
//            // For example, if server sends:
//            // { "conversationId": "...", "sender": "Alex", "text": "Hello", "time": "10:30 AM" }
//            if let dict = data.first as? [String: Any],
//               let sender = dict["sender"] as? String,
//               let text = dict["text"] as? String,
//               let time = dict["time"] as? String,
//               let conversationName = dict["conversationName"] as? String {
//                Task { @MainActor in
//                    self.applyIncomingMessage(conversationName: conversationName, sender: sender, text: text, time: time)
//                }
//            }
//        }
//
//        // Example: typing indicator or unread count updates could also be handled similarly
//        // SocketService.shared.on("typing") { data, ack in ... }
    }

    private func loadInitialConversations() {
//        // For now, mimic your sample data or replace with a REST call to your backend
//        self.conversations = [
//            Conversation(name: "Name", messagePreview: "message preview", time: "time", unreadCount: 1),
//            Conversation(name: "Alex Rivers", messagePreview: "See you at 5!", time: "10:30 AM", unreadCount: 3),
//            Conversation(name: "Jordan Smith", messagePreview: "The files are ready.", time: "Yesterday", unreadCount: 0)
//        ]
    }

    private func applyIncomingMessage(conversationName: String, sender: String, text: String, time: String) {
//        // Update or insert conversation, bump unread, and set preview/time
//        if let idx = conversations.firstIndex(where: { $0.name == conversationName }) {
//            var c = conversations[idx]
//            let newUnread = c.unreadCount + 1
//            let updated = Conversation(name: c.name, messagePreview: text, time: time, unreadCount: newUnread)
//            conversations[idx] = updated
//        } else {
//            let newConversation = Conversation(name: conversationName, messagePreview: text, time: time, unreadCount: 1)
//            conversations.insert(newConversation, at: 0)
//        }
    }

    func sendMessage(to conversationName: String, text: String) {
//        // Adapt payload to your server contract
//        let payload: [String: Any] = [
//            "conversationName": conversationName,
//            "text": text,
//            "time": Self.formattedNow(),
//            "sender": "Me"
//        ]
//        SocketService.shared.emit("message", [payload])
//
//        // Optimistically update UI
//        if let idx = conversations.firstIndex(where: { $0.name == conversationName }) {
//            var c = conversations[idx]
//            let updated = Conversation(name: c.name, messagePreview: text, time: Self.formattedNow(), unreadCount: c.unreadCount)
//            conversations[idx] = updated
//        }
    }

    private static func formattedNow() -> String {
//        let df = DateFormatter()
//        df.timeStyle = .short
//        df.dateStyle = .none
//        return df.string(from: Date())
        return ""
    }
}

