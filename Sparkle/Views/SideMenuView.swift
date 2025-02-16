import SwiftUI
import SwiftData

struct SideMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Chat.createdAt, order: .reverse) private var chats: [Chat]
    @Binding var selectedChat: Chat?
    @Binding var showMenu: Bool
    @State private var showSettings = false
    
    var body: some View {
        List {
            Button(action: createNewChat) {
                Label("New Chat", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            
            if !chats.isEmpty {
                Section("Chats") {
                    ForEach(chats) { chat in
                        HStack {
                            Label(chat.title, systemImage: "message")
                                .lineLimit(1)
                            Spacer()
                            if selectedChat?.id == chat.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChat = chat
                            showMenu = false
                        }
                    }
                    .onDelete(perform: deleteChats)
                }
            }
            
            Section {
                Button(action: {
                    showSettings = true
                    showMenu = false
                }) {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
        .navigationTitle("Sparkle")
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private func createNewChat() {
        let newChat = Chat()
        modelContext.insert(newChat)
        selectedChat = newChat
        showMenu = false
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
}
