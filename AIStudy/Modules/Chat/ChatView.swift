//
//  ChatView.swift
//  AIStudy
//
//  Created by mark on 2025/3/27.
//

import SwiftUI

struct Message: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    
    init(content: String, isUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
    }
    
    init(id: UUID, content: String, isUser: Bool) {
        self.id = id
        self.content = content
        self.isUser = isUser
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
    }
}

struct ChatView: View {
    @State private var inputText = ""
    @State private var messages: [Message] = []
    @State private var isLoading = false
    private let api = DeepSeekAPI()
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("输入消息...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // 添加用户消息
        let userMessageObj = Message(content: userMessage, isUser: true)
        messages.append(userMessageObj)
        inputText = ""
        isLoading = true
        
        // 构建完整的对话历史
        let conversationHistory = messages.map { message in
            ["role": message.isUser ? "user" : "assistant", "content": message.content]
        }
        
        // 发送请求
        Task {
            var assistantResponse = ""
            let assistantMessageId = UUID()
            let assistantMessage = Message(id: assistantMessageId, content: "", isUser: false)
            messages.append(assistantMessage)
            
            for await text in api.streamChatResponse(messages: conversationHistory) {
                assistantResponse.append(text)
                // 更新AI回复消息
                if let index = messages.firstIndex(where: { $0.id == assistantMessageId }) {
                    messages[index] = Message(id: assistantMessageId, content: assistantResponse, isUser: false)
                }
            }
            isLoading = false
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(.init(message.content))
                .textSelection(.enabled)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
            
            if !message.isUser { Spacer() }
        }
    }
}
