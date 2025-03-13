//
//  Components.swift
//  MultiClip
//
//  Created by Adon Omeri on 13/3/2025.
//

import Foundation
import SwiftUI

struct SnippetRow: View {
    let snippet: TextSnippet
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(snippet.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(snippet.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundStyle(.foreground)
                    .font(.system(size: 19))
                    .padding(5)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

struct EditSnippetView: View {
    @Environment(\.dismiss) private var dismiss
    let snippet: TextSnippet
    let onSave: (TextSnippet) -> Void
    let onDelete: () -> Void
    @State private var name: String
    @State private var content: String
    
    init(snippet: TextSnippet, onSave: @escaping (TextSnippet) -> Void, onDelete: @escaping () -> Void) {
        self.snippet = snippet
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: snippet.name)
        _content = State(initialValue: snippet.content)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            
            Text("Content")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                
            TextEditor(text: $content)
                .frame(height: 100)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack {
                Button(role: .destructive, action: {
                    onDelete()
                    dismiss()
                }) {
                    Image(systemName: "trash")
                    Text("Remove")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                
                Spacer()
                
                Button("Cancel") { dismiss() }
                
                Button("Save") {
                    let updatedSnippet = TextSnippet(name: name, content: content)
                    onSave(updatedSnippet)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .padding()
    }
}
