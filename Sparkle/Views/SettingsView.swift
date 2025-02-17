import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showAddEndpoint = false
    @State private var showAddModel = false
    @State private var selectedEndpoint: AzureEndpoint?
    @State private var endpointToRename: AzureEndpoint?
    @State private var newEndpointName = ""
    @State private var showRenameAlert = false
    @State private var modelToRename: (endpoint: AzureEndpoint, model: AzureModelConfig)?
    @State private var newModelName = ""
    @State private var showRenameModelAlert = false
    
    var body: some View {
        List {
            ForEach(viewModel.settings.endpoints.indices, id: \.self) { index in
                let endpoint = viewModel.settings.endpoints[index]
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(endpoint.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Menu {
                                Button {
                                    endpointToRename = endpoint
                                    newEndpointName = endpoint.name
                                    showRenameAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    viewModel.deleteEndpoint(endpoint)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            Text("Base Endpoint:")
                            TextField("", text: Binding(
                                get: { viewModel.settings.endpoints[index].baseEndpoint },
                                set: { viewModel.updateEndpoint(endpoint, baseEndpoint: $0) }
                            ))
                        }
                        
                        HStack {
                            Text("API Key:")
                            SecureField("", text: Binding(
                                get: { viewModel.settings.endpoints[index].apiKey },
                                set: { viewModel.updateEndpoint(endpoint, apiKey: $0) }
                            ))
                        }
                        
                        Divider()
                        
                        Text("Models (\(endpoint.models.count))")
                            .font(.subheadline)
                        
                        ForEach(endpoint.models) { model in
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(model.name)
                                            .font(.subheadline)
                                        Text("Deployment: \(model.deploymentName)")
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Button {
                                            modelToRename = (endpoint, model)
                                            newModelName = model.name
                                            showRenameModelAlert = true
                                        } label: {
                                            Label("Rename", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            viewModel.deleteModel(from: endpoint, model: model)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                HStack {
                                    Text("API Version:")
                                    TextField("", text: Binding(
                                        get: { model.apiVersion },
                                        set: { viewModel.updateModel(endpoint, model: model, apiVersion: $0) }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                }
                                
                                Toggle("Supports Streaming", isOn: Binding(
                                    get: { model.supportsStreaming },
                                    set: { viewModel.updateModel(endpoint, model: model, supportsStreaming: $0) }
                                ))
                                
                                Toggle("Default for Title Generation", isOn: Binding(
                                    get: { model.isDefaultForTitles },
                                    set: { viewModel.updateModel(endpoint, model: model, isDefaultForTitles: $0) }
                                ))
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Button {
                            showAddModel = false
                            selectedEndpoint = endpoint
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showAddModel = true
                            }
                        } label: {
                            Label("Add model", systemImage: "plus.circle")
                        }
                        .padding(.top, 8)
                    }
                }
            }
            
            Section {
                Button("Add Endpoint") {
                    showAddEndpoint = true
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showAddEndpoint) {
            NavigationStack {
                AddEndpointView(viewModel: viewModel, isPresented: $showAddEndpoint)
            }
        }
        .sheet(isPresented: $showAddModel) {
            if let endpoint = selectedEndpoint {
                NavigationStack {
                    AddModelView(viewModel: viewModel, endpoint: endpoint, isPresented: $showAddModel)
                }
            }
        }
        .alert("Rename Endpoint", isPresented: $showRenameAlert) {
            TextField("Name", text: $newEndpointName)
            Button("Cancel", role: .cancel) {
                endpointToRename = nil
                newEndpointName = ""
            }
            Button("Rename") {
                if let endpoint = endpointToRename {
                    viewModel.renameEndpoint(endpoint, newName: newEndpointName)
                }
                endpointToRename = nil
                newEndpointName = ""
            }
        } message: {
            Text("Enter a new name for this endpoint")
        }
        .alert("Rename Model", isPresented: $showRenameModelAlert) {
            TextField("Name", text: $newModelName)
            Button("Cancel", role: .cancel) {
                modelToRename = nil
                newModelName = ""
            }
            Button("Rename") {
                if let (endpoint, model) = modelToRename {
                    viewModel.renameModel(endpoint, model: model, newName: newModelName)
                }
                modelToRename = nil
                newModelName = ""
            }
        } message: {
            Text("Enter a new name for this model")
        }
        .onChange(of: showAddModel) { _, newValue in
            if !newValue {
                selectedEndpoint = nil
            }
        }
    }
}

struct AddEndpointView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var baseEndpoint = ""
    @State private var apiKey = ""
    
    var body: some View {
        Form {
            Section("Endpoint Details") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.never)
                
                TextField("Base Endpoint", text: $baseEndpoint)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.URL)
                
                SecureField("API Key", text: $apiKey)
                    .textInputAutocapitalization(.never)
            }
            
            Section {
                Button("Add Endpoint") {
                    viewModel.addEndpoint(name: name, baseEndpoint: baseEndpoint, apiKey: apiKey)
                    isPresented = false
                }
                .disabled(name.isEmpty || baseEndpoint.isEmpty || apiKey.isEmpty)
            }
        }
        .navigationTitle("Add Endpoint")
        .navigationBarItems(leading: Button("Cancel") {
            isPresented = false
        })
    }
}

struct AddModelView: View {
    @ObservedObject var viewModel: SettingsViewModel
    let endpoint: AzureEndpoint
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var deploymentName = ""
    @State private var supportsStreaming = true
    @State private var isDefaultForTitles = false
    @State private var apiVersion = "2024-02-15-preview"
    
    var body: some View {
        Form {
            Section("Model Details") {
                TextField("Model Name", text: $name)
                    .textInputAutocapitalization(.never)
                
                TextField("Deployment Name", text: $deploymentName)
                    .textInputAutocapitalization(.never)
                
                TextField("API Version", text: $apiVersion)
                    .textInputAutocapitalization(.never)
                
                Toggle("Supports Streaming", isOn: $supportsStreaming)
                Toggle("Default for Title Generation", isOn: $isDefaultForTitles)
            }
            
            Section {
                Button("Add this Model") {
                    viewModel.addModel(
                        to: endpoint,
                        name: name,
                        deploymentName: deploymentName,
                        supportsStreaming: supportsStreaming,
                        isDefaultForTitles: isDefaultForTitles,
                        apiVersion: apiVersion
                    )
                    isPresented = false
                }
                .disabled(name.isEmpty || deploymentName.isEmpty || apiVersion.isEmpty)
            }
        }
        .navigationTitle("Add Model")
        .navigationBarItems(leading: Button("Cancel") {
            isPresented = false
        })
    }
}
