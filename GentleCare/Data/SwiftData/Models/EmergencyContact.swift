//
//  EmergencyContact.swift
//  GentleCare
//
//  Emergency contact information model
//

import Foundation
import SwiftData

@Model
final class EmergencyContact {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - Contact Info

    var name: String
    var relationship: String
    var phoneNumber: String
    var alternatePhone: String?
    var email: String?
    var address: String?

    // MARK: - Priority

    var isPrimary: Bool
    var order: Int

    // MARK: - Notification Preferences

    var notifyOnEmergency: Bool
    var notifyOnMissedMedication: Bool
    var notifyOnAbnormalVitals: Bool
    var notifyOnMissedAppointment: Bool

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships

    var profile: ElderlyProfile?

    // MARK: - Computed Properties

    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return "\(firstInitial)\(lastInitial)"
    }

    var formattedPhone: String {
        // Simple formatting - could be enhanced with proper phone formatting
        phoneNumber
    }

    var callURL: URL? {
        let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        return URL(string: "tel://\(cleaned)")
    }

    var messageURL: URL? {
        let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        return URL(string: "sms://\(cleaned)")
    }

    // MARK: - Initialization

    init(
        name: String,
        relationship: String,
        phoneNumber: String,
        isPrimary: Bool = false,
        order: Int = 0,
        profile: ElderlyProfile? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.relationship = relationship
        self.phoneNumber = phoneNumber
        self.isPrimary = isPrimary
        self.order = order
        self.notifyOnEmergency = true
        self.notifyOnMissedMedication = isPrimary
        self.notifyOnAbnormalVitals = isPrimary
        self.notifyOnMissedAppointment = isPrimary
        self.profile = profile
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func makePrimary() {
        self.isPrimary = true
        self.notifyOnEmergency = true
        self.notifyOnMissedMedication = true
        self.notifyOnAbnormalVitals = true
        self.notifyOnMissedAppointment = true
        self.updatedAt = Date()
    }
}

// MARK: - Common Relationships

enum ContactRelationship: String, CaseIterable, Identifiable {
    case spouse = "Esposo/a"
    case son = "Hijo"
    case daughter = "Hija"
    case sibling = "Hermano/a"
    case parent = "Padre/Madre"
    case grandchild = "Nieto/a"
    case friend = "Amigo/a"
    case neighbor = "Vecino/a"
    case caregiver = "Cuidador"
    case doctor = "Medico"
    case nurse = "Enfermero/a"
    case other = "Otro"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .spouse: return "heart.fill"
        case .son, .daughter: return "figure.and.child.holdinghands"
        case .sibling: return "person.2.fill"
        case .parent: return "figure.2.and.child.holdinghands"
        case .grandchild: return "figure.and.child.holdinghands"
        case .friend: return "person.crop.circle.badge.checkmark"
        case .neighbor: return "house.fill"
        case .caregiver: return "cross.case.fill"
        case .doctor: return "stethoscope"
        case .nurse: return "cross.fill"
        case .other: return "person.fill"
        }
    }
}
