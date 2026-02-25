//
//  HomeView.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/9/26.
//
import Foundation
import SwiftUI


struct HomeView: View {
    let agent: Agent
    @Bindable private var socketService: SocketService = SocketService.shared
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if socketService.conversations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                      	  
                        Text("No conversations yet")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Waiting for clients to connect...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(socketService.conversations) { conversation in
                                NavigationLink(destination: ChatView(
                                    agent: agent,
                                    clientName: conversation.clientName,
                                    socketService: socketService
                                )) {
                                    ConversationRow(conversation: conversation)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)

            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                }
                
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    handleLogout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
        .onAppear {
            connectSocket()
            Task {
                
                
                await load_conversations()
            }
        }
        .onDisappear {
//            socketService.disconnect()
        }
    }
    private func load_conversations() async {
        SocketService.shared.loadConversations()
    }
    
    private func connectSocket() {
        print("🔌 Starting connection...")
        socketService.connect()
        // Call identify immediately - it will queue if not connected yet
        socketService.identify(userType: "agent", userName: agent.username)
    }
    
    private func handleLogout() {
        isLoggingOut = true
        
        Task {
            do {
                try await APIService.shared.logout()
                socketService.disconnect()
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Logout error:", error)
            }
        }
    }
}

#Preview {
    HomeView(agent: Agent())
}
