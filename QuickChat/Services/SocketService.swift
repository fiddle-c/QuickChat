//
//  SocketService.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/9/26.
//

import Foundation
import SocketIO

@Observable
@MainActor
class SocketService {
    static let shared = SocketService()

    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    var isConnected = false
    var conversations: [Conversation] = []
    var messages: [String: [Message]] = [:]
    var isClientTyping: Bool = false
    // Queue for pending emits
    private var pendingEmits: [() -> Void] = []
    
    private init() {}
    
    private func setupSocket() {
        guard manager == nil else { return }
        
        let config: SocketIOClientConfiguration = [
            .log(true),
            .compress,
            .reconnects(true),
            .reconnectAttempts(5),
            .reconnectWait(1000),
            .forceWebsockets(true)
        ]
        
        guard let url = URL(string: Config.socketURL) else {
            print("❌ Invalid socket URL")
            return
        }
        
        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.defaultSocket
        
        // Connection events
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket connected")
            Task {
                self?.isConnected = true
                print("Processing pending emits after connect")
                self?.processPendingEmits()  // Process queued emits
            }
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("❌ Socket disconnected:", data)
            Task {
                self?.isConnected = false
            }
        }
        
        socket?.on(clientEvent: .error) { data, ack in
            print("❌ Socket error:", data)
        }
        print("setting up handlers")
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        // Load conversations
        print("setting up conversations")
        socket?.on("load_conversations") { [weak self] data, ack in
            guard let self = self else { return }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data[0])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let conversations = try decoder.decode([Conversation].self, from: jsonData)
                
                DispatchQueue.main.async {
                    self.conversations = conversations
                    print("✅ Loaded \(conversations.count) conversations")
                }
            } catch {
                print("❌ Error parsing conversations:", error)
            }
        }
        
        print("loading conversation history")
        // Conversation history
        socket?.on("conversation_history") { [weak self] data, ack in
            print("🧪 conversation_history raw:", data)
            
            guard let self = self else { return }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data[0])
                let decoder = JSONDecoder()
                print("before loading history response")
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let historyResponse = try decoder.decode(ConversationHistoryResponse.self, from: jsonData)
                print("after loading history response")
                DispatchQueue.main.async {
                    self.messages[historyResponse.clientName] = historyResponse.messages
                    print("loading history***\n\n\n")
                    
                }
            } catch {
                print("❌ Error parsing history:", error)
            }
        }
        
        // Client typing indicators
        socket?.on("client_typing") { [weak self] data, ack in
            guard let self else { return }
            print("✍️ client_typing:", data)
            DispatchQueue.main.async {
                self.isClientTyping = true
            }
        }
        
        socket?.on("client_stop_typing") { [weak self] data, ack in
            guard let self else { return }
            print("🛑 client_stop_typing:", data)
            DispatchQueue.main.async {
                self.isClientTyping = false
            }
        }
        
        // Receive message
        socket?.on("receive_message") { [weak self] data, ack in
            guard let self = self,
                  let dict = data[0] as? [String: Any],
                  let clientName = dict["clientName"] as? String,
                  let messageText = dict["message"] as? String else {
                return
            }
            
            let timestamp: Date
            if let timestampString = dict["timestamp"] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                timestamp = formatter.date(from: timestampString) ?? Date()
            } else {
                timestamp = Date()
            }
            
            let newMessage = Message(
                id: Int(Date().timeIntervalSince1970 * 1000),
                clientName: clientName,
                message: messageText,
                sender: "client",
                timestamp: timestamp
            )
            
            Task {
                if var msgs = self.messages[clientName] {
                    msgs.append(newMessage)
                    self.messages[clientName] = msgs
                    
                } else {
                    self.messages[clientName] = [newMessage]
                }
            }
        }
    }
    
    
    
    // Process queued emits after connection
    private func processPendingEmits() {
        print("📤 Processing \(pendingEmits.count) pending emits")
        for emit in pendingEmits {
            emit()
        }
        pendingEmits.removeAll()
    }
    
    func connect() {
        print("🔌 Connecting socket...")
        
        if socket == nil {
            setupSocket()
        }
        
        socket?.connect()
    }
    
    func disconnect() {
        print("🔌 Disconnecting socket...")
        socket?.disconnect()
        pendingEmits.removeAll()
        isConnected = false
    }
    
    // Queue emit if not connected
    // Replace the existing safeEmit with this version
    private func safeEmit(_ event: String, _ payload: SocketData) {
        if isConnected {
            socket?.emit(event, payload)
        } else {
            print("⏳ Queueing emit until connected: \(event)")
            pendingEmits.append { [weak self] in
                self?.socket?.emit(event, payload)
            }
        }
    }
    func typingListener(clientName: String) {
        print("typing detected (agent)")
        safeEmit(SocketValues.agentTyping.rawValue, [SocketValues.clientName.rawValue: clientName, SocketValues.agentName.rawValue: "agent"]) // replace agent string with actual agent name if available
    }
    
    func stopTyping(clientName: String) {
        print("stop typing (agent)")
        safeEmit(SocketValues.agentStopTyping.rawValue, [SocketValues.clientName.rawValue: clientName, SocketValues.agentName.rawValue: "agent"]) // replace agent string with actual agent name if available
    }
    
    
    func identify(userType: String, userName: String) {
        print("🔐 Identifying as \(userType): \(userName)")
        safeEmit("identify", ["userType": userType, "userName": userName])
    }
    
    func sendMessage(clientName: String, message: String) {
        print("📤 Sending message to \(clientName)")
        safeEmit("message", ["clientName": clientName, "message": message])
    }
    
    func loadHistory(clientName: String) {
        print("📥 Loading history for \(clientName)")
        safeEmit("load_history", ["clientName": clientName]) // fixed casing
    }
    
    func loadConversations() {
        print("loading conversations")
        safeEmit("load_conversations", [:]) // if your server requires a payload; otherwise emit without payload using another overload
    }
    
 
}


enum SocketValues: String, CodingKey {
    case load_history = "load_history"
    case typing = "typing"
    case stopTyping = "stop_typing"
    case agentTyping = "agent_typing"
    case agentStopTyping = "agent_stop_typing"
    case clientName = "clientName"
    case agentName = "agentName"
}
