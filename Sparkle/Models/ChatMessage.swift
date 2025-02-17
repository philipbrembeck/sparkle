import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp: Date
    var isStreaming: Bool = false
    let endpointId: UUID?
    let modelId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case id, content, isUser, timestamp, isStreaming, endpointId, modelId
    }
}
