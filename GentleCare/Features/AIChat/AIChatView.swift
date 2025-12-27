//
//  AIChatView.swift
//  GentleCare
//
//  AI Chat companion with hybrid intelligence
//

import SwiftUI
import SwiftData

struct AIChatView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.timestamp) private var messages: [ChatMessage]
    @Query private var profiles: [ElderlyProfile]

    // MARK: - State

    @State private var inputText = ""
    @State private var isProcessing = false
    @State private var showingSuggestions = true
    @StateObject private var aiService = HybridAIServiceViewModel()

    @FocusState private var isInputFocused: Bool

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(hex: "1C1C1E")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Chat messages
                chatMessages

                // Suggestions
                if showingSuggestions && messages.isEmpty {
                    suggestionsView
                }

                // Input area
                inputArea
            }
        }
        .navigationTitle("Asistente")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        clearChat()
                    } label: {
                        Label("Limpiar chat", systemImage: "trash")
                    }

                    Button {
                        // Settings
                    } label: {
                        Label("Configuracion IA", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color(hex: "4A90D9"))
                }
            }
        }
    }

    // MARK: - Chat Messages

    private var chatMessages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Welcome message
                    if messages.isEmpty {
                        welcomeMessage
                    }

                    ForEach(messages, id: \.id) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    // Typing indicator
                    if isProcessing {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: isProcessing) { _, newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Welcome Message

    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "4A90D9"))

            VStack(spacing: 8) {
                Text("Hola, \(profiles.first?.firstName ?? "amigo")!")
                    .font(GCTypography.headline1)
                    .foregroundStyle(.white)

                Text("Soy tu asistente de salud. Puedo ayudarte con informacion sobre medicamentos, recordatorios y consejos de bienestar.")
                    .font(GCTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
    }

    // MARK: - Suggestions View

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sugerencias")
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        SuggestionChip(text: suggestion) {
                            inputText = suggestion
                            sendMessage()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }

    private var suggestions: [String] {
        [
            "Cual es mi proxima medicina?",
            "Como estan mis signos vitales?",
            "Tengo alguna cita pronto?",
            "Dame consejos para dormir mejor",
            "Me siento un poco cansado"
        ]
    }

    // MARK: - Input Area

    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))

            HStack(spacing: 12) {
                // Text input
                HStack {
                    TextField("Escribe tu mensaje...", text: $inputText, axis: .vertical)
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white)
                        .lineLimit(1...4)
                        .focused($isInputFocused)

                    if !inputText.isEmpty {
                        Button {
                            inputText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }

                // Voice input
                Button {
                    // Voice input
                    GCHaptic.light.trigger()
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        }
                }

                // Send button
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background {
                            Circle()
                                .fill(inputText.isEmpty ? Color.white.opacity(0.1) : Color(hex: "4A90D9"))
                        }
                }
                .disabled(inputText.isEmpty || isProcessing)
            }
            .padding()
        }
        .background(Color(hex: "1C1C1E"))
    }

    // MARK: - Actions

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage.userMessage(inputText, profile: profiles.first)
        modelContext.insert(userMessage)

        let query = inputText
        inputText = ""
        isInputFocused = false
        showingSuggestions = false
        isProcessing = true

        Task {
            do {
                let response = await aiService.processQuery(query, profile: profiles.first)

                let assistantMessage = ChatMessage.assistantMessage(
                    response.content,
                    provider: response.provider,
                    profile: profiles.first
                )
                assistantMessage.processingTime = response.processingTime

                modelContext.insert(assistantMessage)
                try modelContext.save()

                GCHaptic.light.trigger()
            } catch {
                let errorMessage = ChatMessage.errorMessage(error.localizedDescription, profile: profiles.first)
                modelContext.insert(errorMessage)
                GCHaptic.error.trigger()
            }

            isProcessing = false
        }
    }

    private func clearChat() {
        for message in messages {
            modelContext.delete(message)
        }
        try? modelContext.save()
        showingSuggestions = true
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "4A90D9").opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "4A90D9"))
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(GCTypography.bodyLarge)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(message.isUser ? Color(hex: "4A90D9") : Color.white.opacity(0.1))
                    }

                HStack(spacing: 6) {
                    Text(message.formattedTime)
                        .font(GCTypography.captionSmall)
                        .foregroundStyle(.white.opacity(0.4))

                    if let badge = message.providerBadge, !message.isUser {
                        Text("• \(badge)")
                            .font(GCTypography.captionSmall)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "4A90D9").opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "4A90D9"))
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(y: animationPhase == index ? -4 : 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever()) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

// MARK: - Suggestion Chip

struct SuggestionChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                }
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AIChatView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(try! ModelContainer.createPreview())
}
