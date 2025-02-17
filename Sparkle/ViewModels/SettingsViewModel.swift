import Foundation

class SettingsViewModel: ObservableObject {
    @Published var settings: AzureSettings {
        didSet {
            saveSettings()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: AzureSettings.settingsKey),
           let settings = try? JSONDecoder().decode(AzureSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = .defaultSettings
        }
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: AzureSettings.settingsKey)
        }
    }
    
    func addEndpoint(name: String, baseEndpoint: String, apiKey: String) {
        let newEndpoint = AzureEndpoint(name: name, baseEndpoint: baseEndpoint, apiKey: apiKey, models: [])
        settings.endpoints.append(newEndpoint)
    }
    
    func addModel(to endpoint: AzureEndpoint, name: String, deploymentName: String, supportsStreaming: Bool, isDefaultForTitles: Bool, apiVersion: String = "2024-02-15-preview") {
        guard let index = settings.endpoints.firstIndex(where: { $0.id == endpoint.id }) else { return }
        
        if isDefaultForTitles {
            settings.endpoints.indices.forEach { i in
                settings.endpoints[i].models.indices.forEach { j in
                    settings.endpoints[i].models[j].isDefaultForTitles = false
                }
            }
        }
        
        let newModel = AzureModelConfig(
            name: name,
            deploymentName: deploymentName,
            supportsStreaming: supportsStreaming,
            isDefaultForTitles: isDefaultForTitles,
            apiVersion: apiVersion
        )
        
        settings.endpoints[index].models.append(newModel)
    }
    
    func updateEndpoint(_ endpoint: AzureEndpoint, baseEndpoint: String? = nil, apiKey: String? = nil) {
        guard let index = settings.endpoints.firstIndex(where: { $0.id == endpoint.id }) else { return }
        
        var updatedEndpoint = endpoint
        if let baseEndpoint = baseEndpoint {
            updatedEndpoint.baseEndpoint = baseEndpoint
        }
        if let apiKey = apiKey {
            updatedEndpoint.apiKey = apiKey
        }
        
        settings.endpoints[index] = updatedEndpoint
    }
    
    func updateModel(_ endpoint: AzureEndpoint, model: AzureModelConfig, deploymentName: String? = nil,
                        supportsStreaming: Bool? = nil, isDefaultForTitles: Bool? = nil, apiVersion: String? = nil) {
            guard let endpointIndex = settings.endpoints.firstIndex(where: { $0.id == endpoint.id }),
                  let modelIndex = settings.endpoints[endpointIndex].models.firstIndex(where: { $0.id == model.id }) else { return }
            
            var updatedModel = model
            if let deploymentName = deploymentName {
                updatedModel.deploymentName = deploymentName
            }
            if let supportsStreaming = supportsStreaming {
                updatedModel.supportsStreaming = supportsStreaming
            }
            if let isDefaultForTitles = isDefaultForTitles {
                if isDefaultForTitles {
                    settings.endpoints.indices.forEach { i in
                        settings.endpoints[i].models.indices.forEach { j in
                            settings.endpoints[i].models[j].isDefaultForTitles = false
                        }
                    }
                }
                updatedModel.isDefaultForTitles = isDefaultForTitles
            }
            if let apiVersion = apiVersion {
                updatedModel.apiVersion = apiVersion
            }
            
            settings.endpoints[endpointIndex].models[modelIndex] = updatedModel
        }
    
    func getDefaultTitleModel() -> (AzureEndpoint, AzureModelConfig)? {
        for endpoint in settings.endpoints {
            if let model = endpoint.models.first(where: { $0.isDefaultForTitles }) {
                return (endpoint, model)
            }
        }
        if let firstEndpoint = settings.endpoints.first,
           let firstModel = firstEndpoint.models.first {
            return (firstEndpoint, firstModel)
        }
        return nil
    }
}

extension SettingsViewModel {
    func renameEndpoint(_ endpoint: AzureEndpoint, newName: String) {
        guard let index = settings.endpoints.firstIndex(where: { $0.id == endpoint.id }) else { return }
        var updatedEndpoint = endpoint
        updatedEndpoint.name = newName
        settings.endpoints[index] = updatedEndpoint
    }
    
    func deleteEndpoint(_ endpoint: AzureEndpoint) {
        settings.endpoints.removeAll(where: { $0.id == endpoint.id })
    }
    
    func deleteModel(from endpoint: AzureEndpoint, model: AzureModelConfig) {
           guard let endpointIndex = settings.endpoints.firstIndex(where: { $0.id == endpoint.id }) else { return }
           settings.endpoints[endpointIndex].models.removeAll(where: { $0.id == model.id })
       }
       
       func renameModel(_ endpoint: AzureEndpoint, model: AzureModelConfig, newName: String) {
           guard let endpointIndex = settings.endpoints.firstIndex(where: { $0.id == endpoint.id }),
                 let modelIndex = settings.endpoints[endpointIndex].models.firstIndex(where: { $0.id == model.id }) else { return }
           
           var updatedModel = model
           updatedModel.name = newName
           settings.endpoints[endpointIndex].models[modelIndex] = updatedModel
       }
}
