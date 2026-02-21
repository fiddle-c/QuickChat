//
//  ConversationRow.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 55, height: 55)
                
                Text(conversation.clientName.prefix(1).uppercased())
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(conversation.clientName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(conversation.timeAgo)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Text("\(conversation.messageCount) messages")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
