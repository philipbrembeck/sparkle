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
    @State private var showSidebar = false
    
    init(azureService: AzureOpenAIService) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(azureService: azureService))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if selectedChat == nil {
                    sidebarContent
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Image(systemName: "sparkle")
                                    .font(.title2)
                            }
                        }
                } else {
                    chatView(for: selectedChat!)
                        .navigationTitle(selectedChat!.title)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showSidebar.toggle()
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                }
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: createNewChat) {
                                    Image(systemName: "square.and.pencil")
                                }
                            }
                        }
                }
                
                // Overlay sidebar
                // This seems to be a bit hacky, but I found no other way to archive this with SwiftUI
                if showSidebar {
                    GeometryReader { geometry in
                        if showSidebar {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                                .transition(.opacity.animation(.none))
                                .onTapGesture {
                                    showSidebar = false
                                }
                        }
                        
                        HStack(spacing: 0) {
                            sidebarContent
                                .frame(width: min(geometry.size.width * 0.75, 400))
                                .background(Color(.systemBackground))
                                .offset(x: showSidebar ? 0 : -geometry.size.width)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            if selectedChat == nil && chats.isEmpty {
                createNewChat()
            }
        }
    }
    
    private var sidebarContent: some View {
        List {
            Button(action: createNewChat) {
                Label("New Chat", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            
            if !chats.isEmpty {
                Section("Chats") {
                    ForEach(chats) { chat in
                        Label(chat.title, systemImage: "message")
                            .lineLimit(1)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedChat = chat
                                showSidebar = false
                            }
                    }
                    .onDelete(perform: deleteChats)
                }
            }
            
            Section {
                Button(action: {
                    showSettings = true
                    showSidebar = false
                }) {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
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
            .onChange(of: chat.messages.count) { oldCount, newCount in
                scrollToBottom(proxy: proxy)
            }
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
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
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
            .background(
                colorScheme == .dark ? Color.black : Color.white
            )
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
        showSidebar = false
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

#Preview {
    ContentView(azureService: AzureOpenAIService())
        .modelContainer(for: Chat.self, inMemory: true)
}
