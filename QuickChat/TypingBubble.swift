import SwiftUI

struct TypingBubble: View {
    let isAgent: Bool
    let name: String

    @State private var animateDot = false

    var body: some View {
        HStack {
            if isAgent { Spacer() }

            VStack(alignment: isAgent ? .trailing : .leading, spacing: 4) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(isAgent ? Color.white : Color.primary.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animateDot ? 1.2 : 0.7)
                            .opacity(animateDot ? 1 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animateDot
                            )
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(isAgent ? Color.blue : Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }

            if !isAgent { Spacer() }
        }
        .onAppear {
            animateDot = true
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TypingBubble(isAgent: false, name: "Client")
        TypingBubble(isAgent: true, name: "Agent")
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
