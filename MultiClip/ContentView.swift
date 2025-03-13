import SwiftUI
import SwiftData
import AppKit

struct NewSnippetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    let onSave: (String, String) -> Void
    
    @State private var name: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Snippet")
                .font(.headline)
            
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            
            Text("Content")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
            
            TextEditor(text: $content)
                .frame(height: 120)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack {
                Button("Cancel") { 
                    dismiss() 
                }
                
                Spacer()
                
                Button("Create") {
                    saveAndDismiss()
                }
                .disabled(name.isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding()
        .frame(width: 340)
    }
    
    private func saveAndDismiss() {
        if !name.isEmpty {
            onSave(name, content)
            dismiss()
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var snippets: [TextSnippet]
    @State private var showingEditSheet: TextSnippet?
    @State private var isShowingNewSnippetSheet = false
    @State private var clickedSnippet: TextSnippet? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack {
            if snippets.isEmpty {
                Text("Make a snippet!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(snippets) { snippet in
                        FirstClickView(onClick: {
                            handleSnippetClick(snippet)
                        }) {
                            SnippetRow(snippet: snippet, onEdit: { showingEditSheet = snippet })
                                .contentShape(Rectangle())
                                .padding([.top, .bottom], 2)
                                .padding([.leading, .trailing], 6)
                                .frame(maxWidth: .infinity, alignment:
                                        .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(NSColor.darkGray).opacity(clickedSnippet == snippet ? 0.7 : 0))
                                        .animation(.easeInOut(duration: 0.1), value: clickedSnippet == snippet)
                                )
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .frame(minWidth: 340, maxWidth: 340, minHeight: 300, maxHeight: 750)
        .fixedSize(horizontal: true, vertical: false)
        .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(role: .destructive, action: {
                    if !snippets.isEmpty {
                        showingDeleteAlert = true
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                Button(action: { isShowingNewSnippetSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .background(
            WindowAccessor { window in
                // Make window float on top of others
                window.level = .floating
                window.collectionBehavior = [.canJoinAllSpaces, .stationary]
                
                // Make window appear with proper translucency
                window.isOpaque = false
                window.backgroundColor = NSColor.clear
                
                // Force fixed width
                window.styleMask.remove(.resizable)
                window.styleMask.insert(.resizable)
                
                // Set size constraints
                if let contentView = window.contentView {
                    let widthConstraint = NSLayoutConstraint(
                        item: contentView, attribute: .width,
                        relatedBy: .equal,
                        toItem: nil, attribute: .notAnAttribute,
                        multiplier: 1.0, constant: 340
                    )
                    widthConstraint.isActive = true
                }
                
                // Enable accepting first mouse
                if let tableView = window.contentView?.subviews.compactMap({ $0 as? NSScrollView })
                    .flatMap({ $0.subviews }).first(where: { $0 is NSTableView }) as? NSTableView {
                    tableView.allowsMultipleSelection = false
                }
            }
        )
        .sheet(item: $showingEditSheet) { snippet in
            EditSnippetView(snippet: snippet, onSave: { updatedSnippet in
                snippet.name = updatedSnippet.name
                snippet.content = updatedSnippet.content
            }, onDelete: {
                modelContext.delete(snippet)
            })
            .frame(width: 340)
        }
        .sheet(isPresented: $isShowingNewSnippetSheet) {
            NewSnippetView(isPresented: $isShowingNewSnippetSheet) { name, content in
                addSnippet(name: name, content: content)
            }
        }
        // Reverting back to standard alert
        .alert("Delete All Snippets", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                performDeleteAll()
            }
            .keyboardShortcut(.return, modifiers: [])
        } message: {
            Text("Are you sure you want to delete all snippets? This action cannot be undone.")
        }
        .onAppear {
            // Register for notifications when the view appears
            NotificationCenter.default.addObserver(
                forName: .addNewSnippet,
                object: nil,
                queue: .main
            ) { _ in
                isShowingNewSnippetSheet = true
            }
            
            NotificationCenter.default.addObserver(
                forName: .deleteAllSnippets,
                object: nil,
                queue: .main
            ) { _ in
                if !snippets.isEmpty {
                    showingDeleteAlert = true
                }
            }
        }
        .onDisappear {
            // Remove the observers when the view disappears
            NotificationCenter.default.removeObserver(
                self, 
                name: .addNewSnippet,
                object: nil
            )
            
            NotificationCenter.default.removeObserver(
                self,
                name: .deleteAllSnippets,
                object: nil
            )
        }
    }
    
    private func handleSnippetClick(_ snippet: TextSnippet) {
        // Set clicked snippet immediately
        clickedSnippet = snippet
        
        // Copy to pasteboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(snippet.content, forType: .string)
        
        // Reset the animation state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            clickedSnippet = nil
        }
    }
    
     func addSnippet(name: String, content: String) {
        let newSnippet = TextSnippet(name: name.isEmpty ? "New Snippet" : name, content: content)
        modelContext.insert(newSnippet)
    }
    
     func removeAllSnippets() {
        if !snippets.isEmpty {
            showingDeleteAlert = true
        }
    }
    
    private func performDeleteAll() {
        do {
            try modelContext.delete(model: TextSnippet.self)
        } catch {
            print("Failed to delete all snippets: \(error)")
        }
    }
}
