import Foundation

class SettingsViewModel: ObservableObject {
    @Published var settings: AzureSettings {
        didSet {
            saveSettings()
        }
    }
    
    init() {
        let defaults = UserDefaults.standard
        settings = AzureSettings(
            baseEndpoint: defaults.string(forKey: AzureSettings.baseEndpointKey) ?? "",
            deploymentName: defaults.string(forKey: AzureSettings.deploymentNameKey) ?? "",
            apiKey: defaults.string(forKey: AzureSettings.apiKeyKey) ?? ""
        )
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(settings.baseEndpoint, forKey: AzureSettings.baseEndpointKey)
        defaults.set(settings.deploymentName, forKey: AzureSettings.deploymentNameKey)
        defaults.set(settings.apiKey, forKey: AzureSettings.apiKeyKey)
    }
}
