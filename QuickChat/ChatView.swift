import SwiftUI

struct ChatView: View {
    let agent: Agent
    let clientName: String
    @Bindable var socketService: SocketService
    
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isInputFocused: Bool
    @State var backgroundColor = Color(UIColor.systemBackground)
    @State private var isTyping = false
    @State private var typingWorkItem: DispatchWorkItem?
    @State private var typingTimer: Timer?
    @State private var typingHeartbeatTimer: Timer?
    @State private var isAgentTyping = false
    
    var isClientTyping: Bool {
        socketService.typingClients[clientName] ?? false
    }
    
    var messages: [Message] {
        socketService.messages[clientName] ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    
                    LazyVStack(spacing: 12) {
                        
                        ForEach(messages) { message in
                            
                            MessageBubble(message: message, agentName: agent.username)
                                .id(message.id)
                            
                            
                        }
                        if isClientTyping {
                            TypingBubble(isAgent: false, name: clientName)
                        }
                    }
                    .padding()
                    
                    
                }
                .background(Color(UIColor.systemGroupedBackground))
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: messages.count) { oldValue, newValue in
                    scrollToBottom()
                }
            }
            
            // Input Bar
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onChange(of: messageText) { oldValue, newValue in
                        handleTyping(text: newValue)
                        
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? .gray : Color(hex: "667eea"))
                }
                .disabled(messageText.isEmpty)
            }
            .onChange(of: isClientTyping) { oldValue, newValue in
                if newValue {
                    scrollToBottom()
                }
            }
            .padding()
            .background(backgroundColor)
        }
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
        .navigationTitle(clientName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMessages()
        }
        .onDisappear {
            // Stop typing when leaving chat
            if isAgentTyping {
                socketService.agentStopTyping(clientName: clientName, agentName: agent.username)
            }
            typingTimer?.invalidate()
            typingHeartbeatTimer?.invalidate()
        }
    }

    private func handleTyping(text: String) {
        // If text is empty, stop typing entirely
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            stopTypingNow()
            return
        }

        // If we just started typing, notify once and start heartbeat
        if !isAgentTyping {
            socketService.agentTyping(clientName: clientName, agentName: agent.username)
            isAgentTyping = true
            startTypingHeartbeat()
        }

        // Debounce stop-typing: if no changes for 2s, send stop
        scheduleStopTypingDebounce()
    }

    private func startTypingHeartbeat() {
        typingHeartbeatTimer?.invalidate()
        typingHeartbeatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if isAgentTyping {
                    socketService.agentTyping(clientName: clientName, agentName: agent.username)
                }
            }
        }
    }

    private func scheduleStopTypingDebounce() {
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            Task { @MainActor in
                stopTypingNow()
            }
        }
    }

    private func stopTypingNow() {
        if isAgentTyping {
            socketService.agentStopTyping(clientName: clientName, agentName: agent.username)
            isAgentTyping = false
        }
        typingTimer?.invalidate()
        typingHeartbeatTimer?.invalidate()
    }
    
    private func loadMessages() {
        socketService.loadHistory(clientName: clientName)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add to local messages immediately
        let newMessage = Message(
            id: Int(Date().timeIntervalSince1970 * 1000),
            clientName: clientName,
            message: trimmedMessage,
            sender: "agent",
            timestamp: Date()
        )
        
        if var msgs = socketService.messages[clientName] {
            msgs.append(newMessage)
            socketService.messages[clientName] = msgs
        } else {
            socketService.messages[clientName] = [newMessage]
        }
        
        // Send to server
        socketService.sendMessage(clientName: clientName, message: trimmedMessage)
        
        // Ensure we send stop-typing when message is sent
        if isTyping {
            typingWorkItem?.cancel()
            socketService.stopTyping(clientName: clientName)
            isTyping = false
        }
        
        messageText = ""
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        guard let lastMessage = messages.last else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#Preview {
//    ChatView(agent: Agent(), clientName: "bubbles", socketService: SocketService().shared)
}


