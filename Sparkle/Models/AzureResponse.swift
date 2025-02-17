import Foundation

struct AzureResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct AzureErrorResponse: Codable {
    let error: AzureError
    
    struct AzureError: Codable {
        let message: String
        let type: String?
        let code: String?
    }
}
