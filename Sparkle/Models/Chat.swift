import Foundation
import SwiftData

@Model
class Chat {
    var title: String
    var messages: [ChatMessage]
    var createdAt: Date
    
    init(title: String = "New Chat", messages: [ChatMessage] = [], createdAt: Date = Date()) {
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
    }
}
