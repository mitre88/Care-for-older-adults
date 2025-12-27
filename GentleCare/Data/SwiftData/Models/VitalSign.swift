//
//  VitalSign.swift
//  GentleCare
//
//  Health metrics tracking model
//

import Foundation
import SwiftData

@Model
final class VitalSign {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - Measurement

    var type: VitalSignType
    var value: Double
    var secondaryValue: Double?  // For blood pressure (diastolic)
    var unit: String

    // MARK: - Metadata

    var measuredAt: Date
    var notes: String?
    var source: MeasurementSource
    var isAbnormal: Bool

    // MARK: - Timestamps

    var createdAt: Date

    // MARK: - Relationships

    var profile: ElderlyProfile?

    // MARK: - Computed Properties

    var formattedValue: String {
        switch type {
        case .bloodPressure:
            guard let diastolic = secondaryValue else { return "\(Int(value))" }
            return "\(Int(value))/\(Int(diastolic))"
        case .temperature:
            return String(format: "%.1f", value)
        case .weight:
            return String(format: "%.1f", value)
        case .bloodGlucose:
            return "\(Int(value))"
        default:
            return "\(Int(value))"
        }
    }

    var formattedWithUnit: String {
        "\(formattedValue) \(unit)"
    }

    var status: VitalStatus {
        let range = type.normalRange
        if value < range.lowerBound {
            return .low
        } else if value > range.upperBound {
            return .high
        }
        return .normal
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: measuredAt)
    }

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: measuredAt, relativeTo: Date())
    }

    // MARK: - Initialization

    init(
        type: VitalSignType,
        value: Double,
        secondaryValue: Double? = nil,
        source: MeasurementSource = .manual,
        notes: String? = nil,
        profile: ElderlyProfile? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.value = value
        self.secondaryValue = secondaryValue
        self.unit = type.defaultUnit
        self.measuredAt = Date()
        self.source = source
        self.notes = notes
        self.profile = profile
        self.createdAt = Date()

        // Check if abnormal
        let range = type.normalRange
        self.isAbnormal = value < range.lowerBound || value > range.upperBound
    }
}

// MARK: - Vital Sign Type

enum VitalSignType: String, Codable, CaseIterable, Identifiable {
    case bloodPressure = "Presion Arterial"
    case heartRate = "Ritmo Cardiaco"
    case bloodOxygen = "Oxigeno en Sangre"
    case temperature = "Temperatura"
    case bloodGlucose = "Glucosa en Sangre"
    case weight = "Peso"
    case respiratoryRate = "Frecuencia Respiratoria"

    var id: String { rawValue }

    var defaultUnit: String {
        switch self {
        case .bloodPressure: return "mmHg"
        case .heartRate: return "lpm"
        case .bloodOxygen: return "%"
        case .temperature: return "°C"
        case .bloodGlucose: return "mg/dL"
        case .weight: return "kg"
        case .respiratoryRate: return "resp/min"
        }
    }

    var normalRange: ClosedRange<Double> {
        switch self {
        case .bloodPressure: return 90...120  // Systolic
        case .heartRate: return 60...100
        case .bloodOxygen: return 95...100
        case .temperature: return 36.1...37.2
        case .bloodGlucose: return 70...140
        case .weight: return 45...136
        case .respiratoryRate: return 12...20
        }
    }

    var icon: String {
        switch self {
        case .bloodPressure: return "heart.text.square.fill"
        case .heartRate: return "heart.fill"
        case .bloodOxygen: return "lungs.fill"
        case .temperature: return "thermometer"
        case .bloodGlucose: return "drop.fill"
        case .weight: return "scalemass.fill"
        case .respiratoryRate: return "wind"
        }
    }

    var color: String {
        switch self {
        case .bloodPressure: return "vitalBP"
        case .heartRate: return "vitalHR"
        case .bloodOxygen: return "vitalO2"
        case .temperature: return "vitalTemp"
        case .bloodGlucose: return "vitalGlucose"
        case .weight: return "vitalWeight"
        case .respiratoryRate: return "vitalRespiratory"
        }
    }

    var minValue: Double {
        switch self {
        case .bloodPressure: return 60
        case .heartRate: return 40
        case .bloodOxygen: return 80
        case .temperature: return 35.0
        case .bloodGlucose: return 40
        case .weight: return 30
        case .respiratoryRate: return 8
        }
    }

    var maxValue: Double {
        switch self {
        case .bloodPressure: return 200
        case .heartRate: return 200
        case .bloodOxygen: return 100
        case .temperature: return 42.0
        case .bloodGlucose: return 400
        case .weight: return 200
        case .respiratoryRate: return 40
        }
    }

    var requiresSecondaryValue: Bool {
        self == .bloodPressure
    }

    var secondaryLabel: String? {
        switch self {
        case .bloodPressure: return "Diastolica"
        default: return nil
        }
    }
}

// MARK: - Measurement Source

enum MeasurementSource: String, Codable, CaseIterable, Identifiable {
    case manual = "Entrada Manual"
    case healthKit = "Apple Health"
    case device = "Dispositivo Conectado"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .manual: return "hand.tap.fill"
        case .healthKit: return "heart.text.square.fill"
        case .device: return "sensor.tag.radiowaves.forward.fill"
        }
    }
}

// MARK: - Vital Status

enum VitalStatus: String, CaseIterable, Identifiable {
    case low = "Bajo"
    case normal = "Normal"
    case high = "Alto"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .low: return "vitalLow"
        case .normal: return "vitalNormal"
        case .high: return "vitalHigh"
        }
    }

    var icon: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .normal: return "checkmark.circle.fill"
        case .high: return "arrow.up.circle.fill"
        }
    }
}
