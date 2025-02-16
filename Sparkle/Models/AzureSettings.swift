import Foundation

struct AzureSettings: Equatable {
    var baseEndpoint: String
    var deploymentName: String
    var apiKey: String
    
    static let baseEndpointKey = "AzureBaseEndpoint"
    static let deploymentNameKey = "AzureDeploymentName"
    static let apiKeyKey = "AzureApiKey"
    
    var fullEndpointURL: URL? {
        let cleanBaseEndpoint = baseEndpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let urlString = "\(cleanBaseEndpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=2024-02-15-preview"
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString)
    }
    
    static func == (lhs: AzureSettings, rhs: AzureSettings) -> Bool {
        return lhs.baseEndpoint == rhs.baseEndpoint &&
               lhs.deploymentName == rhs.deploymentName &&
               lhs.apiKey == rhs.apiKey
    }
}
