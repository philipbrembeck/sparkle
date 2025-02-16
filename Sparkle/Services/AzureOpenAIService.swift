import Foundation

class AzureOpenAIService {
    private let settings: AzureSettings
    
    init(settings: AzureSettings) {
        self.settings = settings
    }
    
    func streamChat(message: String, onReceive: @escaping (String) -> Void) async throws {
        guard let url = settings.fullEndpointURL else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(settings.apiKey, forHTTPHeaderField: "api-key")
        
        let messageBody = [
            "messages": [
                ["role": "user", "content": message]
            ],
            "max_tokens": 800,
            "temperature": 0.7,
            "stream": true
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: messageBody)
        
        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        var streamedContent = ""
        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }
        
        let data = line.dropFirst(6).data(using: .utf8)
        guard let data = data,
              let response = try? JSONDecoder().decode(StreamResponse.self, from: data),
              let content = response.choices.first?.delta.content else { continue }
              
        streamedContent += content
        onReceive(streamedContent)
        }
    }
}
