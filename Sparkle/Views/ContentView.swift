import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isInputFocused: Bool
    @State private var showSettings = false
    @Query(sort: \Chat.createdAt, order: .reverse) private var chats: [Chat]
    @State private var selectedChat: Chat?
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    init(azureService: AzureOpenAIService) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(azureService: azureService))
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BG,
                        colorScheme == .dark ? .black : .white
                    ]),
                    startPoint: .top,
                    endPoint: colorScheme == .dark ? .init(x: 0.5, y: 0.30) : .init(x: 0.5, y: 0.22)
                )
                .ignoresSafeArea()
                
                List(selection: $selectedChat) {
                    Button(action: createNewChat) {
                        Label("New Chat", systemImage: "plus")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .listRowBackground(Color.primary.opacity(0.1))
                    .buttonStyle(.borderless)
                    
                    if !chats.isEmpty {
                        Section {
                            ForEach(chats) { chat in
                                chatRow(for: chat)
                                    .tag(chat)
                            }
                            .onDelete(perform: deleteChats)
                        } header: {
                            Text("Recent Chats")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.subheadline)
                                .textCase(nil)
                        }
                    }
                    
                    Section {
                        Button(action: { showSettings = true }) {
                            Label("Setup Sparkle with Azure OpenAI", systemImage: "gearshape")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        .listRowBackground(Color.primary.opacity(0.1))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(systemName: "sparkle")
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        } detail: {
            if let chat = selectedChat {
                chatView(for: chat)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(chat.title)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: createNewChat) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
            } else {
                ContentUnavailableView {
                    VStack(spacing: 20) {
                        Circle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "sparkle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.primary)
                            )
                        
                        Text("Welcome to Sparkle")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Start a new conversation or select an existing chat")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: createNewChat) {
                            Text("New Chat")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            if selectedChat == nil && !chats.isEmpty {
                selectedChat = chats.first
            } else if chats.isEmpty {
                createNewChat()
            }
        }
    }
    
    private func chatRow(for chat: Chat) -> some View {
            HStack(spacing: 12) {
                Image(systemName: "message")
                    .font(.system(size: 24))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.title)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    if let lastMessage = chat.messages.last {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if let timestamp = chat.messages.last?.timestamp {
                    Text(timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                }
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.primary.opacity(0.1))
    }
    
    private func chatView(for chat: Chat) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInputFocused = false
                    }
                
                LazyVStack(spacing: 24) {
                    ForEach(chat.messages) { message in
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
            .onChange(of: chat.messages.count) { scrollToBottom(proxy: proxy) }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScrollToBottom"))) { _ in
                scrollToBottom(proxy: proxy)
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
                                .fill(Color.primary.opacity(0.1))
                        )
                        .disabled(viewModel.isLoading)
                    
                    Button {
                        sendMessage(in: chat)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                    }
                    .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color.black : .white)
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = selectedChat?.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func createNewChat() {
        let newChat = Chat()
        modelContext.insert(newChat)
        selectedChat = newChat
    }
    
    private func deleteChats(at offsets: IndexSet) {
        for index in offsets {
            let chat = chats[index]
            if selectedChat?.id == chat.id {
                selectedChat = nil
            }
            modelContext.delete(chat)
        }
    }
    
    private func sendMessage(in chat: Chat) {
        viewModel.sendMessage(in: chat)
    }
}
