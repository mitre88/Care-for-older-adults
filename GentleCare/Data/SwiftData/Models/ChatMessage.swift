//
//  ChatMessage.swift
//  GentleCare
//
//  AI Chat conversation model
//

import Foundation
import SwiftData

@Model
final class ChatMessage {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - Content

    var content: String
    var role: MessageRole
    var timestamp: Date

    // MARK: - Input Type

    var isVoiceInput: Bool

    // MARK: - AI Metadata

    var aiProvider: AIProvider?
    var processingTime: TimeInterval?
    var tokensUsed: Int?
    var contextUsed: [String]?

    // MARK: - Error Handling

    var isError: Bool
    var errorMessage: String?

    // MARK: - Timestamps

    var createdAt: Date

    // MARK: - Relationships

    var profile: ElderlyProfile?

    // MARK: - Computed Properties

    var isUser: Bool {
        role == .user
    }

    var isAssistant: Bool {
        role == .assistant
    }

    var isSystem: Bool {
        role == .system
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    var providerBadge: String? {
        guard let provider = aiProvider else { return nil }
        switch provider {
        case .appleIntelligence: return "En dispositivo"
        case .openAI: return "OpenAI"
        case .hybrid: return "Hibrido"
        }
    }

    // MARK: - Initialization

    init(
        content: String,
        role: MessageRole,
        isVoiceInput: Bool = false,
        aiProvider: AIProvider? = nil,
        profile: ElderlyProfile? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.role = role
        self.timestamp = Date()
        self.isVoiceInput = isVoiceInput
        self.aiProvider = aiProvider
        self.isError = false
        self.profile = profile
        self.createdAt = Date()
    }

    // MARK: - Factory Methods

    static func userMessage(_ content: String, isVoice: Bool = false, profile: ElderlyProfile? = nil) -> ChatMessage {
        ChatMessage(content: content, role: .user, isVoiceInput: isVoice, profile: profile)
    }

    static func assistantMessage(_ content: String, provider: AIProvider, profile: ElderlyProfile? = nil) -> ChatMessage {
        ChatMessage(content: content, role: .assistant, aiProvider: provider, profile: profile)
    }

    static func systemMessage(_ content: String, profile: ElderlyProfile? = nil) -> ChatMessage {
        ChatMessage(content: content, role: .system, profile: profile)
    }

    static func errorMessage(_ error: String, profile: ElderlyProfile? = nil) -> ChatMessage {
        var message = ChatMessage(content: "Lo siento, hubo un problema.", role: .assistant, profile: profile)
        message.isError = true
        message.errorMessage = error
        return message
    }
}

// MARK: - Message Role

enum MessageRole: String, Codable, CaseIterable, Identifiable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .user: return "Tu"
        case .assistant: return "GentleCare"
        case .system: return "Sistema"
        }
    }
}

// MARK: - AI Provider

enum AIProvider: String, Codable, CaseIterable, Identifiable {
    case appleIntelligence = "apple_intelligence"
    case openAI = "openai"
    case hybrid = "hybrid"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appleIntelligence: return "Apple Intelligence"
        case .openAI: return "OpenAI"
        case .hybrid: return "Hibrido"
        }
    }

    var icon: String {
        switch self {
        case .appleIntelligence: return "apple.logo"
        case .openAI: return "cloud.fill"
        case .hybrid: return "arrow.triangle.branch"
        }
    }

    var isPrivate: Bool {
        self == .appleIntelligence
    }
}
