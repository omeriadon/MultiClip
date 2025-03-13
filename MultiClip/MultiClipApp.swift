//
//  MultiClipApp.swift
//  MultiClip
//
//  Created by Adon Omeri on 13/3/2025.
//

import SwiftUI
import SwiftData

// Notification names
extension Notification.Name {
    static let addNewSnippet = Notification.Name("addNewSnippet")
    static let deleteAllSnippets = Notification.Name("deleteAllSnippets")
}

@Model
class TextSnippet {
    var name: String
    var content: String
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            if let menu = NSApplication.shared.mainMenu {
                for title in ["File", "Window", "View", "Help"] {
                    if let item = menu.items.first(where: { $0.title == title }) {
                        menu.removeItem(item)
                    }
                }
            }
        }
    }
}

@main
struct MultiClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(.ultraThinMaterial)
                .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 340, height: 500)
        .modelContainer(for: TextSnippet.self)
        .windowStyle(.hiddenTitleBar) // Optional: For a cleaner look
        // Adding commands to show app when a menu item is selected
        .commands {
            CommandGroup(replacing: .appVisibility ) { }
            CommandGroup(replacing: .help ) { }
            CommandGroup(replacing: .newItem ) { }
            CommandGroup(replacing: .saveItem ) { }
            CommandGroup(replacing: .importExport ) { }
            CommandGroup(replacing: .printItem ) { }
            CommandGroup(replacing: .saveItem ) { }
            CommandGroup(replacing: .sidebar ) { }
        }
        .commands {
            CommandGroup(replacing: .windowList ) { }
            CommandGroup(replacing: .windowArrangement ) { }
            CommandGroup(replacing: .singleWindowList ) { }
            CommandGroup(replacing: .toolbar ) { }
            CommandGroup(replacing: .windowSize) { }
        }
        
        .commands {
            CommandMenu("Utility") {
                Button("Close Window") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut("w", modifiers: .command)
                
                Divider()

                Button("Add Snippet") {
                    NotificationCenter.default.post(name: .addNewSnippet, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Delete All Snippets") {
                    NotificationCenter.default.post(name: .deleteAllSnippets, object: nil)
                }
                .keyboardShortcut(.delete, modifiers: [.command, .option])
            }
        }
    }
}
