import Foundation

struct AzureModelConfig: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var deploymentName: String
    var supportsStreaming: Bool
    var isDefaultForTitles: Bool
    var apiVersion: String
    
    init(name: String, deploymentName: String, supportsStreaming: Bool, isDefaultForTitles: Bool, apiVersion: String = "2024-02-15-preview") {
        self.id = UUID()
        self.name = name
        self.deploymentName = deploymentName
        self.supportsStreaming = supportsStreaming
        self.isDefaultForTitles = isDefaultForTitles
        self.apiVersion = apiVersion
    }
    
    static func == (lhs: AzureModelConfig, rhs: AzureModelConfig) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AzureEndpoint: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var baseEndpoint: String
    var apiKey: String
    var models: [AzureModelConfig]
    
    init(name: String, baseEndpoint: String, apiKey: String, models: [AzureModelConfig]) {
        self.id = UUID()
        self.name = name
        self.baseEndpoint = baseEndpoint
        self.apiKey = apiKey
        self.models = models
    }
    
    var fullEndpointURL: (String, String) -> URL? {
            { deploymentName, apiVersion in
                let cleanBaseEndpoint = baseEndpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let urlString = "\(cleanBaseEndpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)"
                return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString)
            }
        }
    
    static func == (lhs: AzureEndpoint, rhs: AzureEndpoint) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AzureSettings: Codable, Equatable {
    var endpoints: [AzureEndpoint]
    
    static let settingsKey = "AzureSettings"
    
    static var defaultSettings: AzureSettings {
        AzureSettings(endpoints: [])
    }
}
