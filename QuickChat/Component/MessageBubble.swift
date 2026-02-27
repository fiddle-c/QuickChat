//
//  MessageBubble.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let agentName: String
    
    var body: some View {
        HStack {
            if message.isAgent {
                Spacer()
            }
            
            VStack(alignment: message.isAgent ? .trailing : .leading, spacing: 4) {
                Text(message.isAgent ? agentName : message.clientName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.message)
                    .padding(12)
                    .background(message.isAgent ? .quickPrimary : Color.white)
                    .foregroundColor(message.isAgent ? .white : .primary)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isAgent ? .trailing : .leading)
            
            if !message.isAgent {
                Spacer()
            }
        }
    }
}
