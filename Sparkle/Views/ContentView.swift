import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isInputFocused: Bool
    
    init(azureService: AzureOpenAIService) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(azureService: azureService))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isInputFocused = false
                            }
                        
                        LazyVStack(spacing: 24) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding(.vertical)
                    }
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in
                            isInputFocused = false
                        }
                    )
                    .onChange(of: viewModel.messages.count) { oldCount, newCount in
                        scrollToBottom(proxy: proxy)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScrollToBottom"))) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Message...", text: $viewModel.inputMessage, axis: .vertical)
                            .focused($isInputFocused)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                            .disabled(viewModel.isLoading)
                        
                        Button(action: viewModel.sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                    }
                    .padding()
                }
                .background(
                    colorScheme == .dark ? Color.black : Color.white
                )
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(systemName: "sparkle")
                        .font(.title2)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}
