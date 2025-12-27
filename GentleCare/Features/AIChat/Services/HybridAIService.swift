//
//  HybridAIService.swift
//  GentleCare
//
//  Hybrid AI service combining Apple Intelligence and OpenAI
//

import Foundation
import SwiftUI

// MARK: - AI Response

struct AIResponse {
    let content: String
    let provider: AIProvider
    let processingTime: TimeInterval
    let wasPrivacyPreserving: Bool
}

// MARK: - Hybrid AI Service ViewModel

@MainActor
class HybridAIServiceViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isProcessing = false
    @Published var currentProvider: AIProvider?
    @Published var lastError: String?

    // MARK: - Services

    private let appleIntelligence = AppleIntelligenceService()
    private let openAIService = OpenAIService()

    // MARK: - Configuration

    private var preferredMode: AIMode = .hybrid
    private let networkMonitor = NetworkMonitor()

    // MARK: - Process Query

    func processQuery(_ query: String, profile: ElderlyProfile?) async -> AIResponse {
        let startTime = Date()
        isProcessing = true
        lastError = nil

        defer {
            isProcessing = false
        }

        // Determine routing
        let routing = determineRouting(for: query, profile: profile)
        currentProvider = routing.provider

        do {
            let content: String

            switch routing.provider {
            case .appleIntelligence:
                content = await processWithAppleIntelligence(query: query, profile: profile)

            case .openAI:
                content = try await processWithOpenAI(query: query, profile: profile)

            case .hybrid:
                content = try await processHybrid(query: query, profile: profile)
            }

            let processingTime = Date().timeIntervalSince(startTime)

            return AIResponse(
                content: content,
                provider: routing.provider,
                processingTime: processingTime,
                wasPrivacyPreserving: routing.provider == .appleIntelligence
            )

        } catch {
            lastError = error.localizedDescription

            // Fallback to on-device
            let fallbackContent = await processWithAppleIntelligence(query: query, profile: profile)
            let processingTime = Date().timeIntervalSince(startTime)

            return AIResponse(
                content: fallbackContent,
                provider: .appleIntelligence,
                processingTime: processingTime,
                wasPrivacyPreserving: true
            )
        }
    }

    // MARK: - Routing

    private func determineRouting(for query: String, profile: ElderlyProfile?) -> RoutingDecision {
        let mode = profile?.preferredAIMode ?? preferredMode

        // User preference check
        switch mode {
        case .onDevice:
            return RoutingDecision(provider: .appleIntelligence, reason: .userPreference)
        case .cloud:
            if networkMonitor.isConnected {
                return RoutingDecision(provider: .openAI, reason: .userPreference)
            } else {
                return RoutingDecision(provider: .appleIntelligence, reason: .networkUnavailable)
            }
        case .hybrid:
            break
        }

        // Privacy check
        if containsSensitiveContent(query) {
            return RoutingDecision(provider: .appleIntelligence, reason: .privacySensitive)
        }

        // Network check
        guard networkMonitor.isConnected else {
            return RoutingDecision(provider: .appleIntelligence, reason: .networkUnavailable)
        }

        // Query complexity
        let queryType = classifyQuery(query)

        switch queryType {
        case .simple, .reminder:
            return RoutingDecision(provider: .appleIntelligence, reason: .simpleQuery)

        case .medicalAdvice, .emotionalSupport, .complex:
            return RoutingDecision(provider: .openAI, reason: .complexQuery)

        case .healthAnalysis:
            return RoutingDecision(provider: .hybrid, reason: .dataPreprocessing)
        }
    }

    private func containsSensitiveContent(_ query: String) -> Bool {
        let sensitiveTerms = ["contrasena", "password", "tarjeta", "banco", "ssn", "seguro social"]
        let lowercased = query.lowercased()
        return sensitiveTerms.contains { lowercased.contains($0) }
    }

    private func classifyQuery(_ query: String) -> QueryType {
        let lowercased = query.lowercased()

        // Medical advice
        let medicalPatterns = ["debo tomar", "es seguro", "efecto secundario", "interaccion",
                               "sintoma", "doctor", "medicina", "tratamiento", "enfermedad"]
        if medicalPatterns.contains(where: { lowercased.contains($0) }) {
            return .medicalAdvice
        }

        // Emotional support
        let emotionalPatterns = ["siento", "ansioso", "preocupado", "miedo", "solo",
                                  "ayudame", "estresado", "triste", "deprimido"]
        if emotionalPatterns.contains(where: { lowercased.contains($0) }) {
            return .emotionalSupport
        }

        // Health analysis
        let analysisPatterns = ["tendencia", "promedio", "historial", "comparar", "analizar"]
        if analysisPatterns.contains(where: { lowercased.contains($0) }) {
            return .healthAnalysis
        }

        // Reminders
        let reminderPatterns = ["recordar", "cuando", "proxima", "horario", "cita"]
        if reminderPatterns.contains(where: { lowercased.contains($0) }) {
            return .reminder
        }

        // Simple queries
        let wordCount = query.split(separator: " ").count
        if wordCount < 10 {
            return .simple
        }

        return .complex
    }

    // MARK: - Processing Methods

    private func processWithAppleIntelligence(query: String, profile: ElderlyProfile?) async -> String {
        await appleIntelligence.process(query: query, profile: profile)
    }

    private func processWithOpenAI(query: String, profile: ElderlyProfile?) async throws -> String {
        try await openAIService.chat(query: query, profile: profile)
    }

    private func processHybrid(query: String, profile: ElderlyProfile?) async throws -> String {
        // Pre-process with Apple Intelligence
        let context = await appleIntelligence.buildContext(profile: profile)

        // Get response from OpenAI with context
        let response = try await openAIService.chatWithContext(
            query: query,
            context: context,
            profile: profile
        )

        // Post-process for personalization
        return await appleIntelligence.personalize(response: response, profile: profile)
    }
}

// MARK: - Routing Decision

struct RoutingDecision {
    let provider: AIProvider
    let reason: RoutingReason
}

enum RoutingReason {
    case userPreference
    case privacySensitive
    case networkUnavailable
    case simpleQuery
    case complexQuery
    case dataPreprocessing
}

enum QueryType {
    case simple
    case reminder
    case medicalAdvice
    case emotionalSupport
    case healthAnalysis
    case complex
}

// MARK: - Network Monitor

class NetworkMonitor: ObservableObject {
    @Published var isConnected = true

    init() {
        // In production, use NWPathMonitor
        // For now, assume connected
    }
}

// MARK: - Apple Intelligence Service

class AppleIntelligenceService {

    func process(query: String, profile: ElderlyProfile?) async -> String {
        // Simulate on-device processing
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s

        let greeting = getTimeBasedGreeting()
        let name = profile?.firstName ?? "amigo"

        // Simple pattern matching for on-device responses
        let lowercased = query.lowercased()

        if lowercased.contains("proxima") && lowercased.contains("medic") {
            if let med = profile?.activeMedications.first,
               let time = med.timeUntilNextDose {
                return "\(greeting), \(name). Tu proxima medicina es \(med.name) \(med.formattedDosage), \(time)."
            }
            return "\(greeting), \(name). No tienes medicamentos programados proximamente."
        }

        if lowercased.contains("cita") {
            if let apt = profile?.upcomingAppointments.first {
                return "\(greeting), \(name). Tu proxima cita es con \(apt.doctorName), \(apt.relativeDate) en \(apt.location)."
            }
            return "\(greeting), \(name). No tienes citas programadas."
        }

        if lowercased.contains("signos") || lowercased.contains("vitales") {
            return "\(greeting), \(name). Puedo ver tus signos vitales en la seccion de Salud. Toca el boton de Salud en el menu inferior."
        }

        // Default response
        return "\(greeting), \(name). Entiendo tu pregunta. Para obtener una respuesta mas completa, te recomiendo consultar con tu medico o cuidador."
    }

    func buildContext(profile: ElderlyProfile?) async -> String {
        guard let profile else { return "" }

        var context = "Paciente: \(profile.fullName), \(profile.age) anos. "

        if !profile.medicalConditions.isEmpty {
            context += "Condiciones: \(profile.medicalConditions.joined(separator: ", ")). "
        }

        if !profile.allergies.isEmpty {
            context += "Alergias: \(profile.allergies.joined(separator: ", ")). "
        }

        let meds = profile.activeMedications.map { "\($0.name) \($0.formattedDosage)" }
        if !meds.isEmpty {
            context += "Medicamentos: \(meds.joined(separator: ", ")). "
        }

        return context
    }

    func personalize(response: String, profile: ElderlyProfile?) async -> String {
        guard let profile else { return response }

        // Add personalization
        let greeting = getTimeBasedGreeting()
        return "\(greeting), \(profile.firstName). \(response)"
    }

    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buenos dias"
        case 12..<18: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }
}

// MARK: - OpenAI Service

class OpenAIService {

    private let baseURL = "https://api.openai.com/v1/chat/completions"

    func chat(query: String, profile: ElderlyProfile?) async throws -> String {
        try await chatWithContext(query: query, context: nil, profile: profile)
    }

    func chatWithContext(query: String, context: String?, profile: ElderlyProfile?) async throws -> String {
        // Build system prompt
        let systemPrompt = buildSystemPrompt(context: context, profile: profile)

        // In production, this would call the actual OpenAI API
        // For now, return a simulated response

        try await Task.sleep(nanoseconds: 1_000_000_000) // 1s

        return generateSimulatedResponse(for: query, profile: profile)
    }

    private func buildSystemPrompt(context: String?, profile: ElderlyProfile?) -> String {
        """
        Eres GentleCare AI, un companero de salud compasivo para personas mayores.

        INSTRUCCIONES IMPORTANTES:
        - Usa lenguaje claro y sencillo
        - Se paciente, calido y alentador
        - Nunca des diagnosticos medicos especificos
        - Siempre recomienda consultar con profesionales de salud
        - Habla en un tono calmado y tranquilizador
        - Responde en espanol

        CONTEXTO DEL PACIENTE:
        \(context ?? "No hay contexto disponible")

        Responde de manera util considerando el contexto de salud del paciente.
        """
    }

    private func generateSimulatedResponse(for query: String, profile: ElderlyProfile?) -> String {
        let lowercased = query.lowercased()

        if lowercased.contains("cansado") || lowercased.contains("fatiga") {
            return "Entiendo que te sientes cansado. El cansancio puede tener muchas causas. Te sugiero descansar un poco, mantenerte hidratado y asegurarte de dormir lo suficiente. Si el cansancio persiste varios dias, seria bueno comentarlo con tu medico en la proxima cita."
        }

        if lowercased.contains("dormir") || lowercased.contains("sueno") {
            return "Para mejorar tu sueno, te recomiendo establecer una rutina: acuestate y levantate a la misma hora, evita las pantallas una hora antes de dormir, mantén tu habitacion fresca y oscura, y evita la cafeina por la tarde. Un te caliente de manzanilla puede ayudar a relajarte."
        }

        if lowercased.contains("ejercicio") || lowercased.contains("actividad") {
            return "El ejercicio suave es excelente para tu salud. Caminar 15-20 minutos al dia, hacer estiramientos suaves o ejercicios de silla son buenas opciones. Recuerda siempre calentar antes y escuchar a tu cuerpo. Si tienes alguna condicion medica, consulta con tu medico antes de comenzar una nueva rutina."
        }

        if lowercased.contains("ansiedad") || lowercased.contains("preocupado") || lowercased.contains("nervioso") {
            return "Entiendo que te sientes preocupado. Es normal sentirse asi a veces. Intenta respirar profundamente: inhala por 4 segundos, manten 4 segundos, exhala por 4 segundos. Hablar con alguien de confianza tambien puede ayudar. Si estos sentimientos persisten, considera hablar con un profesional."
        }

        // Default response
        return "Gracias por compartir eso conmigo. Tu bienestar es muy importante. Te recomiendo mantener tus medicamentos al dia, seguir una alimentacion balanceada y no dudes en contactar a tu medico si tienes alguna preocupacion sobre tu salud."
    }
}
