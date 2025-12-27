//
//  ElderlyProfile.swift
//  GentleCare
//
//  Main user profile model for the elderly person being cared for
//

import Foundation
import SwiftData

@Model
final class ElderlyProfile {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var bloodType: BloodType?
    var allergies: [String]
    var medicalConditions: [String]
    var emergencyNotes: String?

    @Attribute(.externalStorage)
    var profileImageData: Data?

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Preferences

    var prefersDarkMode: Bool
    var textSizeMultiplier: Double
    var enableVoiceFeedback: Bool
    var enableHapticFeedback: Bool
    var preferredLanguage: String

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \Medication.profile)
    var medications: [Medication] = []

    @Relationship(deleteRule: .cascade, inverse: \VitalSign.profile)
    var vitalSigns: [VitalSign] = []

    @Relationship(deleteRule: .cascade, inverse: \MedicalAppointment.profile)
    var appointments: [MedicalAppointment] = []

    @Relationship(deleteRule: .cascade, inverse: \EmergencyContact.profile)
    var emergencyContacts: [EmergencyContact] = []

    // MARK: - Computed Properties

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var initials: String {
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        return "\(firstInitial)\(lastInitial)"
    }

    var activeMedications: [Medication] {
        medications.filter { $0.isActive }
    }

    var upcomingAppointments: [MedicalAppointment] {
        appointments
            .filter { $0.isUpcoming }
            .sorted { $0.appointmentDate < $1.appointmentDate }
    }

    var primaryEmergencyContact: EmergencyContact? {
        emergencyContacts.first { $0.isPrimary }
    }

    // MARK: - Initialization

    init(
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        bloodType: BloodType? = nil,
        allergies: [String] = [],
        medicalConditions: [String] = []
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.bloodType = bloodType
        self.allergies = allergies
        self.medicalConditions = medicalConditions
        self.prefersDarkMode = true
        self.textSizeMultiplier = 1.2
        self.enableVoiceFeedback = true
        self.enableHapticFeedback = true
        self.preferredLanguage = "es"
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func updateTimestamp() {
        self.updatedAt = Date()
    }
}

// MARK: - Blood Type

enum BloodType: String, Codable, CaseIterable, Identifiable {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    case oPositive = "O+"
    case oNegative = "O-"

    var id: String { rawValue }

    var displayName: String { rawValue }
}
