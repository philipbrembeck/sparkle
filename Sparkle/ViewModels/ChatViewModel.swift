import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage = ""
    @Published var isLoading = false
    
    private let azureService: AzureOpenAIService
    
    init(azureService: AzureOpenAIService) {
        self.azureService = azureService
    }
    
    func sendMessage() {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: inputMessage, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        let messageToSend = inputMessage
        inputMessage = ""
        isLoading = true
        
        // Create an initial assistant message for streaming
        let assistantMessage = ChatMessage(content: "", isUser: false, timestamp: Date(), isStreaming: true)
        messages.append(assistantMessage)
        
        Task {
            do {
                try await azureService.streamChat(message: messageToSend) { content in
                    Task { @MainActor in
                        if let index = self.messages.indices.last {
                            self.messages[index].content = content
                        }
                    }
                }
                
                await MainActor.run {
                    if let index = self.messages.indices.last {
                        self.messages[index].isStreaming = false
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    if let index = self.messages.indices.last {
                        self.messages[index].content = "Error: \(error.localizedDescription)"
                        self.messages[index].isStreaming = false
                    }
                    isLoading = false
                }
            }
        }
    }
}
