import SwiftUI

struct StructuredChatView: View {
    @State private var prompt = ""
    @State private var jsonResponse = ""
    @State private var isLoading = false
    @State private var error: String?
    private let api = DeepSeekAPI()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // JSON 响应区域
            ScrollView {
                VStack(alignment: .leading) {
                    Text("JSON 响应")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    if jsonResponse.isEmpty {
                        Text("暂无数据")
                            .foregroundColor(.gray)
                    } else {
                        Text(jsonResponse)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // 错误提示
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // 输入区域
            VStack(alignment: .leading) {
                Text("输入提示词")
                    .font(.headline)
                TextEditor(text: $prompt)
                    .focused($isFocused)
                    .frame(height: 100)
                    .border(Color.gray.opacity(0.2), width: 1)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // 发送按钮
            Button(action: sendPrompt) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("发送")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(.vertical)
        .navigationTitle("结构化对话")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendPrompt() {
        let promptText = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !promptText.isEmpty else { return }
        
        isLoading = true
        error = nil
        jsonResponse = ""
        isFocused = false
        
        let messages = [
            ["role": "system", "content": "你是一个JSON数据生成器。你只能返回符合指定结构的JSON数据，不要包含任何其他信息或解释。"],
            ["role": "user", "content": prompt]
        ]
        
        api.fetchChatResponse(
            messages: messages,
            responseFormat: ["type": "json_object"]
        ) { result in
            isLoading = false
            switch result {
            case let .success(response):
                jsonResponse = response
            case let .failure(error):
                self.error = error.localizedDescription
            }
        }
    }
}

#Preview {
    StructuredChatView()
}
