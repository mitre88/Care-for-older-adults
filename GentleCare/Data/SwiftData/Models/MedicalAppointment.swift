//
//  MedicalAppointment.swift
//  GentleCare
//
//  Medical appointments management model
//

import Foundation
import SwiftData

@Model
final class MedicalAppointment {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - Details

    var title: String
    var doctorName: String
    var specialty: MedicalSpecialty
    var location: String
    var address: String?
    var phoneNumber: String?

    // MARK: - Timing

    var appointmentDate: Date
    var duration: TimeInterval
    var reminderOffset: TimeInterval  // How long before to remind

    // MARK: - Information

    var notes: String?
    var preparationInstructions: String?
    var status: AppointmentStatus

    // MARK: - Calendar Integration

    var calendarEventIdentifier: String?

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships

    var profile: ElderlyProfile?

    // MARK: - Computed Properties

    var isUpcoming: Bool {
        appointmentDate > Date() && status == .scheduled
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(appointmentDate)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(appointmentDate)
    }

    var isPast: Bool {
        appointmentDate < Date()
    }

    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es")
        return formatter.string(from: appointmentDate)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es")
        return formatter.string(from: appointmentDate)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: appointmentDate)
    }

    var daysUntil: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: appointmentDate)
        return components.day ?? 0
    }

    var relativeDate: String {
        if isToday {
            return "Hoy a las \(formattedTime)"
        } else if isTomorrow {
            return "Manana a las \(formattedTime)"
        } else if daysUntil <= 7 && daysUntil > 0 {
            return "En \(daysUntil) dias"
        } else {
            return formattedDate
        }
    }

    var endTime: Date {
        appointmentDate.addingTimeInterval(duration)
    }

    // MARK: - Initialization

    init(
        title: String,
        doctorName: String,
        specialty: MedicalSpecialty,
        location: String,
        address: String? = nil,
        appointmentDate: Date,
        duration: TimeInterval = 3600,
        profile: ElderlyProfile? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.doctorName = doctorName
        self.specialty = specialty
        self.location = location
        self.address = address
        self.appointmentDate = appointmentDate
        self.duration = duration
        self.reminderOffset = 86400  // 24 hours default
        self.status = .scheduled
        self.profile = profile
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func markAsCompleted() {
        self.status = .completed
        self.updatedAt = Date()
    }

    func markAsCancelled() {
        self.status = .cancelled
        self.updatedAt = Date()
    }

    func reschedule(to newDate: Date) {
        self.appointmentDate = newDate
        self.status = .rescheduled
        self.updatedAt = Date()
    }
}

// MARK: - Medical Specialty

enum MedicalSpecialty: String, Codable, CaseIterable, Identifiable {
    case generalPractitioner = "Medicina General"
    case cardiologist = "Cardiologia"
    case neurologist = "Neurologia"
    case orthopedist = "Traumatologia"
    case dermatologist = "Dermatologia"
    case ophthalmologist = "Oftalmologia"
    case dentist = "Odontologia"
    case psychiatrist = "Psiquiatria"
    case endocrinologist = "Endocrinologia"
    case rheumatologist = "Reumatologia"
    case urologist = "Urologia"
    case gastroenterologist = "Gastroenterologia"
    case pulmonologist = "Neumologia"
    case oncologist = "Oncologia"
    case geriatrician = "Geriatria"
    case physicalTherapy = "Fisioterapia"
    case laboratory = "Laboratorio"
    case imaging = "Imagenologia"
    case other = "Otro"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cardiologist: return "heart.fill"
        case .neurologist: return "brain.head.profile"
        case .orthopedist: return "figure.walk"
        case .ophthalmologist: return "eye.fill"
        case .dentist: return "mouth.fill"
        case .pulmonologist: return "lungs.fill"
        case .gastroenterologist: return "stomach.fill"
        case .laboratory: return "testtube.2"
        case .imaging: return "xray"
        case .physicalTherapy: return "figure.flexibility"
        case .geriatrician: return "person.badge.clock.fill"
        default: return "stethoscope"
        }
    }
}

// MARK: - Appointment Status

enum AppointmentStatus: String, Codable, CaseIterable, Identifiable {
    case scheduled = "Programada"
    case completed = "Completada"
    case cancelled = "Cancelada"
    case rescheduled = "Reprogramada"
    case noShow = "No asistio"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .scheduled: return "calendar.badge.clock"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .rescheduled: return "arrow.triangle.2.circlepath"
        case .noShow: return "person.fill.xmark"
        }
    }

    var color: String {
        switch self {
        case .scheduled: return "gcPrimary"
        case .completed: return "gcSuccess"
        case .cancelled: return "gcError"
        case .rescheduled: return "gcWarning"
        case .noShow: return "gcSecondaryText"
        }
    }
}
