import Foundation

class AzureOpenAIService: ObservableObject {
    @Published var settings: AzureSettings {
        didSet {
            if currentEndpoint == nil || !settings.endpoints.contains(where: { $0.id == currentEndpoint?.id }) {
                currentEndpoint = settings.endpoints.first
                currentModel = settings.endpoints.first?.models.first
            }
        }
    }
    @Published var currentEndpoint: AzureEndpoint?
    @Published var currentModel: AzureModelConfig?
    
    init() {
        if let data = UserDefaults.standard.data(forKey: AzureSettings.settingsKey),
           let settings = try? JSONDecoder().decode(AzureSettings.self, from: data) {
            self.settings = settings
            self.currentEndpoint = settings.endpoints.first
            self.currentModel = settings.endpoints.first?.models.first
        } else {
            self.settings = .defaultSettings
        }
    }
    
    func streamChat(message: String, onReceive: @escaping (String) -> Void) async throws {
        guard let endpoint = currentEndpoint,
              let model = currentModel else {
            throw NSError(domain: "AzureOpenAIService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Please configure Azure OpenAI settings and select a model"])
        }
        
        guard let url = endpoint.fullEndpointURL(model.deploymentName, model.apiVersion) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(endpoint.apiKey, forHTTPHeaderField: "api-key")
        
        var messageBody: [String: Any] = [
            "messages": [
                ["role": "user", "content": message]
            ]
        ]
        
        if model.supportsStreaming {
            messageBody["max_tokens"] = 800
            messageBody["temperature"] = 0.7
            messageBody["stream"] = true
        } else {
            messageBody["max_completion_tokens"] = 800
            messageBody["stream"] = false
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: messageBody)
        
        if model.supportsStreaming {
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
        } else {
            // Non-streaming response
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            // Check for error response
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorResponse = try? JSONDecoder().decode(AzureErrorResponse.self, from: data) {
                    throw NSError(domain: "AzureOpenAI",
                                code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message])
                } else {
                    throw URLError(.badServerResponse)
                }
            }
            
            let azureResponse = try JSONDecoder().decode(AzureResponse.self, from: data)
            if let content = azureResponse.choices.first?.message.content {
                onReceive(content)
            } else {
                throw NSError(domain: "AzureOpenAI",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "No content in response"])
            }
        }
    }
}

extension AzureOpenAIService {
    func selectEndpoint(_ endpoint: AzureEndpoint) {
        self.currentEndpoint = endpoint
        if !endpoint.models.contains(where: { $0.id == currentModel?.id }) {
            self.currentModel = endpoint.models.first
        }
    }
    
    func selectModel(_ model: AzureModelConfig) {
        guard let endpoint = currentEndpoint,
              endpoint.models.contains(where: { $0.id == model.id }) else {
            return
        }
        self.currentModel = model
    }
}
