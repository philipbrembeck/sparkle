import SwiftUI

@main
struct SparkleApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var azureService = AzureOpenAIService()
    
    var body: some Scene {
        WindowGroup {
            ContentView(azureService: azureService)
                .onChange(of: settingsViewModel.settings) { _, newSettings in
                    azureService.updateSettings(newSettings)
                }
                .environmentObject(settingsViewModel)
        }
    }
}
