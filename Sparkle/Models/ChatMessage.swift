import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp: Date
    var isStreaming: Bool = false
}
