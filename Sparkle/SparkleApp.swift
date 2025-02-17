import SwiftUI
import SwiftData

@main
struct SparkleApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var azureService = AzureOpenAIService()
    
    let container: ModelContainer
    
    init() {
        let schema = Schema([Chat.self])
        do {
            container = try ModelContainer(for: schema, configurations: [])
        } catch {
            fatalError("Could not initialize SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(azureService: azureService)
                .environmentObject(settingsViewModel)
                .modelContainer(container)
                .onChange(of: settingsViewModel.settings) { _, newSettings in
                    azureService.settings = newSettings
                }
        }
    }
}
