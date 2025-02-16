import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Azure OpenAI Configuration")) {
                TextField("Base Endpoint", text: $viewModel.settings.baseEndpoint)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.URL)
                
                TextField("Deployment Name", text: $viewModel.settings.deploymentName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("API Key", text: $viewModel.settings.apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            Section(footer: Text("Example Base Endpoint: https://your-resource.openai.azure.com")) {
                if let url = viewModel.settings.fullEndpointURL {
                    Text("Full URL Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(url.absoluteString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
