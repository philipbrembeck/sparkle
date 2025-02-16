import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    @State private var height: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                Avatar(isUser: false)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assistant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    MarkdownText(content: message.content)
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            Group {
                                if message.isStreaming {
                                    HStack {
                                        Text(message.content)
                                            .opacity(0)
                                            .overlay(
                                                Rectangle()
                                                    .fill(Color.secondary)
                                                    .frame(width: 2)
                                                    .opacity(0.5)
                                                    .offset(x: -4),
                                                alignment: .trailing
                                            )
                                    }
                                }
                            }
                        )
                        .id(message.id) // Important for scrolling
                }
                
                Spacer()
            } else {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("You")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(message.content)
                        .textSelection(.enabled)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Avatar(isUser: true)
            }
        }
        .padding(.horizontal)
        .onChange(of: message.content) { _ in
            withAnimation {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ScrollToBottom"),
                    object: nil
                )
            }
        }
    }
}

struct Avatar: View {
    let isUser: Bool
    
    var body: some View {
        Circle()
            .fill(isUser ? Color.blue : Color.purple)
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: isUser ? "person.fill" : "sparkle")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            )
    }
}
