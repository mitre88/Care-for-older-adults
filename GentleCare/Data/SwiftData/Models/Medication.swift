//
//  Medication.swift
//  GentleCare
//
//  Medication model with scheduling and tracking
//

import Foundation
import SwiftData

@Model
final class Medication {

    // MARK: - Identity

    @Attribute(.unique) var id: UUID
    var name: String
    var genericName: String?
    var dosage: String
    var dosageUnit: DosageUnit
    var frequency: MedicationFrequency
    var instructions: String?
    var prescribedBy: String?
    var pharmacy: String?
    var refillDate: Date?

    // MARK: - Stock

    var currentStock: Int
    var lowStockThreshold: Int

    // MARK: - Appearance (for identification)

    var color: MedicationColor
    var shape: MedicationShape

    @Attribute(.externalStorage)
    var imageData: Data?

    // MARK: - Status

    var isActive: Bool
    var startDate: Date
    var endDate: Date?

    // MARK: - Schedule

    var scheduledTimes: [Date]
    var daysOfWeek: [Int]  // 1-7, Sunday = 1

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships

    var profile: ElderlyProfile?

    @Relationship(deleteRule: .cascade, inverse: \MedicationDose.medication)
    var doses: [MedicationDose] = []

    // MARK: - Computed Properties

    var needsRefill: Bool {
        currentStock <= lowStockThreshold
    }

    var formattedDosage: String {
        "\(dosage) \(dosageUnit.rawValue)"
    }

    var nextScheduledTime: Date? {
        guard isActive else { return nil }

        let now = Date()
        let calendar = Calendar.current

        // Check today and tomorrow
        for dayOffset in 0...7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            let weekday = calendar.component(.weekday, from: day)

            guard daysOfWeek.contains(weekday) else { continue }

            for time in scheduledTimes.sorted() {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: day)
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute

                if let scheduledDate = calendar.date(from: dateComponents),
                   scheduledDate > now {
                    return scheduledDate
                }
            }
        }
        return nil
    }

    var timeUntilNextDose: String? {
        guard let nextTime = nextScheduledTime else { return nil }

        let interval = nextTime.timeIntervalSince(Date())
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "en \(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "en \(minutes) minutos"
        } else {
            return "ahora"
        }
    }

    var todaysDoses: [MedicationDose] {
        let calendar = Calendar.current
        return doses.filter { calendar.isDateInToday($0.scheduledTime) }
    }

    var pendingDosesToday: [MedicationDose] {
        todaysDoses.filter { $0.status == .pending }
    }

    var takenDosesToday: Int {
        todaysDoses.filter { $0.status == .taken }.count
    }

    // MARK: - Initialization

    init(
        name: String,
        genericName: String? = nil,
        dosage: String,
        dosageUnit: DosageUnit,
        frequency: MedicationFrequency,
        scheduledTimes: [Date],
        daysOfWeek: [Int] = [1, 2, 3, 4, 5, 6, 7],
        color: MedicationColor = .white,
        shape: MedicationShape = .round,
        profile: ElderlyProfile? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.genericName = genericName
        self.dosage = dosage
        self.dosageUnit = dosageUnit
        self.frequency = frequency
        self.scheduledTimes = scheduledTimes
        self.daysOfWeek = daysOfWeek
        self.color = color
        self.shape = shape
        self.currentStock = 30
        self.lowStockThreshold = 7
        self.isActive = true
        self.startDate = Date()
        self.profile = profile
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func decrementStock() {
        if currentStock > 0 {
            currentStock -= 1
            updatedAt = Date()
        }
    }

    func refillStock(amount: Int) {
        currentStock += amount
        refillDate = nil
        updatedAt = Date()
    }
}

// MARK: - Dosage Unit

enum DosageUnit: String, Codable, CaseIterable, Identifiable {
    case mg = "mg"
    case ml = "ml"
    case tablet = "tableta"
    case capsule = "capsula"
    case drops = "gotas"
    case patch = "parche"
    case injection = "inyeccion"
    case units = "unidades"

    var id: String { rawValue }
}

// MARK: - Medication Frequency

enum MedicationFrequency: String, Codable, CaseIterable, Identifiable {
    case onceDaily = "Una vez al dia"
    case twiceDaily = "Dos veces al dia"
    case threeTimesDaily = "Tres veces al dia"
    case fourTimesDaily = "Cuatro veces al dia"
    case everyOtherDay = "Cada dos dias"
    case weekly = "Semanal"
    case asNeeded = "Segun sea necesario"
    case custom = "Personalizado"

    var id: String { rawValue }

    var timesPerDay: Int {
        switch self {
        case .onceDaily: return 1
        case .twiceDaily: return 2
        case .threeTimesDaily: return 3
        case .fourTimesDaily: return 4
        case .everyOtherDay: return 1
        case .weekly: return 1
        case .asNeeded: return 0
        case .custom: return 0
        }
    }
}

// MARK: - Medication Color

enum MedicationColor: String, Codable, CaseIterable, Identifiable {
    case white = "Blanco"
    case blue = "Azul"
    case pink = "Rosa"
    case yellow = "Amarillo"
    case orange = "Naranja"
    case red = "Rojo"
    case green = "Verde"
    case purple = "Morado"
    case brown = "Marron"
    case beige = "Beige"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .white: return "medicationWhite"
        case .blue: return "medicationBlue"
        case .pink: return "medicationPink"
        case .yellow: return "medicationYellow"
        case .orange: return "medicationOrange"
        case .red: return "medicationRed"
        case .green: return "medicationGreen"
        case .purple: return "medicationPurple"
        case .brown: return "medicationBrown"
        case .beige: return "medicationBeige"
        }
    }
}

// MARK: - Medication Shape

enum MedicationShape: String, Codable, CaseIterable, Identifiable {
    case round = "Redonda"
    case oval = "Ovalada"
    case capsule = "Capsula"
    case square = "Cuadrada"
    case triangle = "Triangular"
    case diamond = "Diamante"
    case oblong = "Oblonga"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .round: return "circle.fill"
        case .oval: return "oval.fill"
        case .capsule: return "capsule.fill"
        case .square: return "square.fill"
        case .triangle: return "triangle.fill"
        case .diamond: return "diamond.fill"
        case .oblong: return "rectangle.fill"
        }
    }
}
