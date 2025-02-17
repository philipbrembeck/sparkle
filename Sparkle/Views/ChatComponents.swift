import SwiftUI

struct ModelSelectionView: View {
    @ObservedObject var azureService: AzureOpenAIService
    
    var body: some View {
        Menu {
            ForEach(azureService.settings.endpoints) { endpoint in
                Menu(endpoint.name) {
                    ForEach(endpoint.models) { model in
                        Button {
                            azureService.selectEndpoint(endpoint)
                            azureService.selectModel(model)
                        } label: {
                            HStack {
                                Text(model.name)
                                if model.id == azureService.currentModel?.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(azureService.currentEndpoint?.name ?? "Select Endpoint")
                Text("/")
                Text(azureService.currentModel?.name ?? "Select Model")
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.subheadline)
            .padding(8)
            .background(Color.primary.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct ChatInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    let chat: Chat
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 12) {
                ModelSelectionView(azureService: viewModel.azureService)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    TextField("Message...", text: $viewModel.inputMessage, axis: .vertical)
                        .focused($isFocused)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary.opacity(0.1))
                        )
                        .disabled(viewModel.isLoading)
                    
                    Button {
                        viewModel.sendMessage(in: chat)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                    }
                    .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}
