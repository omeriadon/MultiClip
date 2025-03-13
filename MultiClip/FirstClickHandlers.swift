import SwiftUI
import AppKit

// Custom NSTableView that accepts first mouse click
class FirstClickTableView: NSTableView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

// Custom NSScrollView that accepts first mouse click
class FirstClickScrollView: NSScrollView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

// SwiftUI wrapper for a list that accepts first mouse click
struct FirstClickList<Content: View>: NSViewRepresentable {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeNSView(context: Context) -> NSView {
        let scrollView = FirstClickScrollView()
        let hostingView = NSHostingView(rootView: content)
        scrollView.documentView = hostingView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let scrollView = nsView as? FirstClickScrollView,
           let hostingView = scrollView.documentView as? NSHostingView<Content> {
            hostingView.rootView = content
        }
    }
}

// Custom clickable view that accepts first mouse
struct FirstClickView<Content: View>: NSViewRepresentable {
    var content: Content
    var onClick: () -> Void
    
    init(onClick: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onClick = onClick
    }
    
    func makeNSView(context: Context) -> NSView {
        let hostingView = ClickThroughHostingView(rootView: content, onClick: onClick)
        return hostingView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let hostingView = nsView as? ClickThroughHostingView<Content> {
            hostingView.rootView = content
        }
    }
}

class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    var onClick: () -> Void
    
    init(rootView: Content, onClick: @escaping () -> Void) {
        self.onClick = onClick
        super.init(rootView: rootView)
    }
    
    required init(rootView: Content) {
        self.onClick = {}
        super.init(rootView: rootView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        onClick()
        super.mouseDown(with: event)
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
