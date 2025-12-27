//
//  MedicationDose.swift
//  GentleCare
//
//  Tracks individual medication doses
//

import Foundation
import SwiftData

@Model
final class MedicationDose {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - Timing

    var scheduledTime: Date
    var takenTime: Date?

    // MARK: - Status

    var status: DoseStatus
    var notes: String?
    var skippedReason: String?

    // MARK: - Timestamps

    var createdAt: Date

    // MARK: - Relationships

    var medication: Medication?

    // MARK: - Computed Properties

    var isOverdue: Bool {
        guard status == .pending else { return false }
        // 1 hour grace period
        return Date() > scheduledTime.addingTimeInterval(3600)
    }

    var formattedScheduledTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
    }

    var formattedTakenTime: String? {
        guard let takenTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: takenTime)
    }

    var wasOnTime: Bool {
        guard let takenTime, status == .taken else { return false }
        // Consider on time if taken within 30 minutes of scheduled
        let difference = abs(takenTime.timeIntervalSince(scheduledTime))
        return difference <= 1800
    }

    // MARK: - Initialization

    init(scheduledTime: Date, medication: Medication? = nil) {
        self.id = UUID()
        self.scheduledTime = scheduledTime
        self.status = .pending
        self.medication = medication
        self.createdAt = Date()
    }

    // MARK: - Methods

    func markAsTaken(notes: String? = nil) {
        self.status = .taken
        self.takenTime = Date()
        self.notes = notes

        // Decrement medication stock
        medication?.decrementStock()
    }

    func markAsSkipped(reason: String?) {
        self.status = .skipped
        self.skippedReason = reason
    }

    func markAsMissed() {
        self.status = .missed
    }
}

// MARK: - Dose Status

enum DoseStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pendiente"
    case taken = "Tomada"
    case skipped = "Omitida"
    case missed = "Perdida"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .taken: return "checkmark.circle.fill"
        case .skipped: return "arrow.uturn.right.circle.fill"
        case .missed: return "xmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .pending: return "gcWarning"
        case .taken: return "gcSuccess"
        case .skipped: return "gcSecondaryText"
        case .missed: return "gcError"
        }
    }
}
