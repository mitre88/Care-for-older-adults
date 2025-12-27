//
//  ModelContainer+Configuration.swift
//  GentleCare
//
//  SwiftData configuration for local-only storage
//

import Foundation
import SwiftData

extension ModelContainer {

    /// Creates the shared ModelContainer with all app models
    static func createShared() throws -> ModelContainer {
        let schema = Schema([
            ElderlyProfile.self,
            Medication.self,
            MedicationDose.self,
            VitalSign.self,
            MedicalAppointment.self,
            ChatMessage.self,
            EmergencyContact.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none  // Local only - no cloud sync
        )

        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }

    /// Creates an in-memory container for previews and testing
    static func createPreview() throws -> ModelContainer {
        let schema = Schema([
            ElderlyProfile.self,
            Medication.self,
            MedicationDose.self,
            VitalSign.self,
            MedicalAppointment.self,
            ChatMessage.self,
            EmergencyContact.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )

        // Populate with sample data for previews
        Task { @MainActor in
            PreviewData.populate(context: container.mainContext)
        }

        return container
    }
}

// MARK: - Preview Data

@MainActor
enum PreviewData {

    static func populate(context: ModelContext) {
        // Create sample profile
        let profile = ElderlyProfile(
            firstName: "Maria",
            lastName: "Garcia",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -78, to: Date())!,
            bloodType: .aPositive,
            allergies: ["Penicillin", "Sulfa"],
            medicalConditions: ["Hypertension", "Type 2 Diabetes"]
        )
        context.insert(profile)

        // Create sample medications
        let medications = [
            Medication(
                name: "Lisinopril",
                genericName: "Lisinopril",
                dosage: "10",
                dosageUnit: .mg,
                frequency: .onceDaily,
                scheduledTimes: [createTime(hour: 8, minute: 0)],
                color: .blue,
                shape: .round,
                profile: profile
            ),
            Medication(
                name: "Metformin",
                genericName: "Metformin HCL",
                dosage: "500",
                dosageUnit: .mg,
                frequency: .twiceDaily,
                scheduledTimes: [createTime(hour: 8, minute: 0), createTime(hour: 20, minute: 0)],
                color: .white,
                shape: .oval,
                profile: profile
            ),
            Medication(
                name: "Aspirin",
                genericName: "Acetylsalicylic Acid",
                dosage: "81",
                dosageUnit: .mg,
                frequency: .onceDaily,
                scheduledTimes: [createTime(hour: 8, minute: 0)],
                color: .orange,
                shape: .round,
                profile: profile
            )
        ]

        medications.forEach { context.insert($0) }

        // Create sample vital signs
        let vitals = [
            VitalSign(type: .bloodPressure, value: 128, secondaryValue: 82, profile: profile),
            VitalSign(type: .heartRate, value: 72, profile: profile),
            VitalSign(type: .bloodOxygen, value: 97, profile: profile),
            VitalSign(type: .bloodGlucose, value: 118, profile: profile),
            VitalSign(type: .weight, value: 156, profile: profile)
        ]

        vitals.forEach { context.insert($0) }

        // Create sample appointment
        let appointment = MedicalAppointment(
            title: "Checkup cardiologico",
            doctorName: "Dr. Rodriguez",
            specialty: .cardiologist,
            location: "Hospital Central",
            address: "Av. Principal 123",
            appointmentDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            profile: profile
        )
        context.insert(appointment)

        // Create emergency contact
        let contact = EmergencyContact(
            name: "Carlos Garcia",
            relationship: "Hijo",
            phoneNumber: "+1 555-123-4567",
            isPrimary: true,
            profile: profile
        )
        context.insert(contact)

        try? context.save()
    }

    private static func createTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
