//
//  ContentView.swift
//  AIStudy
//
//  Created by mark on 2025/3/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ChatView()) {
                    Text("Chat")
                }
                
                NavigationLink(destination: StructuredChatView()) {
                    Text("StructuredChat")
                }
            }
            .navigationTitle("AI Study")
        }
    }
}

#Preview {
    ContentView()
}
