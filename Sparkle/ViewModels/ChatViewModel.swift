import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage = ""
    @Published var isLoading = false
    
    let azureService: AzureOpenAIService
    
    init(azureService: AzureOpenAIService) {
        self.azureService = azureService
    }
    
    func generateTitle(for chat: Chat, firstMessage: String) async {
        let prompt = "Based on this first message, generate a very short and concise title (max 4 words) for this chat conversation: \"\(firstMessage)\""
        
        var finalTitle = ""
        do {
            try await azureService.streamChat(message: prompt) { content in
                finalTitle = content
            }
            
            let cleanedTitle = finalTitle.trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            await MainActor.run {
                chat.title = cleanedTitle
            }
        } catch {
            print("Failed to generate title: \(error)")
            await MainActor.run {
                chat.title = "New Chat"
            }
        }
    }
    
    func sendMessage(in chat: Chat) {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: inputMessage, isUser: true, timestamp: Date())
        chat.messages.append(userMessage)
        
        let messageToSend = inputMessage
        inputMessage = ""
        isLoading = true
        
        // Check if this is the first message and generate a title
        if chat.messages.count == 1 {
            Task {
                await generateTitle(for: chat, firstMessage: messageToSend)
            }
        }
        
        // Create an initial assistant message for streaming
        let assistantMessage = ChatMessage(content: "", isUser: false, timestamp: Date(), isStreaming: true)
        chat.messages.append(assistantMessage)
        
        Task {
            do {
                try await azureService.streamChat(message: messageToSend) { content in
                    Task { @MainActor in
                        if let index = chat.messages.indices.last {
                            chat.messages[index].content = content
                        }
                    }
                }
                
                await MainActor.run {
                    if let index = chat.messages.indices.last {
                        chat.messages[index].isStreaming = false
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    if let index = chat.messages.indices.last {
                        chat.messages[index].content = "Error: \(error.localizedDescription)"
                        chat.messages[index].isStreaming = false
                    }
                    isLoading = false
                }
            }
        }
    }
}
