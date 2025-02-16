import SwiftUI

@main
struct SparkleApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(azureService: AzureOpenAIService(settings: settingsViewModel.settings))
        }
    }
}
