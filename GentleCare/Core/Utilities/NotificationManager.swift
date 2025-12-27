//
//  NotificationManager.swift
//  GentleCare
//
//  Handles local notifications for medications, appointments, and reminders
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {

    // MARK: - Singleton

    static let shared = NotificationManager()

    // MARK: - Published State

    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    // MARK: - Private Properties

    private let center = UNUserNotificationCenter.current()

    // MARK: - Initialization

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Medication Notifications

    func scheduleMedicationReminder(for medication: Medication) async {
        guard isAuthorized else { return }

        // Cancel existing notifications for this medication
        cancelNotifications(for: medication.id.uuidString)

        // Schedule notifications for each scheduled time
        for (index, time) in medication.scheduledTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Hora de tu medicina"
            content.body = "\(medication.name) - \(medication.formattedDosage)"
            content.sound = .default
            content.categoryIdentifier = "MEDICATION_REMINDER"
            content.userInfo = [
                "medicationId": medication.id.uuidString,
                "type": "medication"
            ]

            // Create trigger based on time
            var components = Calendar.current.dateComponents([.hour, .minute], from: time)

            // Set to repeat based on frequency
            switch medication.frequency {
            case .onceDaily, .twiceDaily, .threeTimesDaily, .fourTimesDaily:
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(medication.id.uuidString)-\(index)",
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)

            case .everyOtherDay:
                // For every other day, we use a different approach
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(medication.id.uuidString)-\(index)",
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)

            case .weekly:
                components.weekday = Calendar.current.component(.weekday, from: Date())
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(medication.id.uuidString)-\(index)",
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)

            case .asNeeded, .custom:
                // No scheduled notifications for as-needed or custom medications
                break
            }
        }

        await refreshPendingNotifications()
    }

    func scheduleRefillReminder(for medication: Medication) async {
        guard isAuthorized, medication.needsRefill else { return }

        let content = UNMutableNotificationContent()
        content.title = "Recarga necesaria"
        content.body = "Tu medicamento \(medication.name) esta por agotarse. Quedan \(medication.currentStock) \(medication.dosageUnit.rawValue)"
        content.sound = .default
        content.categoryIdentifier = "REFILL_REMINDER"
        content.userInfo = [
            "medicationId": medication.id.uuidString,
            "type": "refill"
        ]

        // Trigger in 1 hour if not already notified
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        let request = UNNotificationRequest(
            identifier: "refill-\(medication.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    // MARK: - Appointment Notifications

    func scheduleAppointmentReminder(for appointment: MedicalAppointment) async {
        guard isAuthorized else { return }

        // Cancel existing notifications
        cancelNotifications(for: "appointment-\(appointment.id.uuidString)")

        let content = UNMutableNotificationContent()
        content.title = "Cita medica proxima"
        content.body = "\(appointment.specialty.rawValue) con \(appointment.doctorName) en \(appointment.location)"
        content.sound = .default
        content.categoryIdentifier = "APPOINTMENT_REMINDER"
        content.userInfo = [
            "appointmentId": appointment.id.uuidString,
            "type": "appointment"
        ]

        // Schedule reminder 60 minutes before appointment
        let reminderMinutes = 60
        let reminderDate = appointment.appointmentDate.addingTimeInterval(-Double(reminderMinutes * 60))

        guard reminderDate > Date() else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "appointment-\(appointment.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
        await refreshPendingNotifications()
    }

    // MARK: - General Notifications

    func scheduleVitalReminder(type: VitalSignType, at time: Date) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de salud"
        content.body = "Es hora de registrar tu \(type.rawValue)"
        content.sound = .default
        content.categoryIdentifier = "VITAL_REMINDER"
        content.userInfo = [
            "vitalType": type.rawValue,
            "type": "vital"
        ]

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "vital-\(type.rawValue)",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    // MARK: - Notification Management

    func cancelNotifications(for identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllMedicationNotifications(for medicationId: UUID) {
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.contains(medicationId.uuidString) }
                .map { $0.identifier }

            self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    func refreshPendingNotifications() async {
        let requests = await center.pendingNotificationRequests()
        await MainActor.run {
            pendingNotifications = requests
        }
    }

    // MARK: - Notification Categories

    func registerNotificationCategories() {
        // Medication category
        let takeMedicationAction = UNNotificationAction(
            identifier: "TAKE_MEDICATION",
            title: "Tomar",
            options: .foreground
        )

        let skipMedicationAction = UNNotificationAction(
            identifier: "SKIP_MEDICATION",
            title: "Omitir",
            options: .destructive
        )

        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takeMedicationAction, skipMedicationAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Appointment category
        let viewAppointmentAction = UNNotificationAction(
            identifier: "VIEW_APPOINTMENT",
            title: "Ver detalles",
            options: .foreground
        )

        let appointmentCategory = UNNotificationCategory(
            identifier: "APPOINTMENT_REMINDER",
            actions: [viewAppointmentAction],
            intentIdentifiers: [],
            options: []
        )

        // Refill category
        let refillCategory = UNNotificationCategory(
            identifier: "REFILL_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        // Vital category
        let recordVitalAction = UNNotificationAction(
            identifier: "RECORD_VITAL",
            title: "Registrar",
            options: .foreground
        )

        let vitalCategory = UNNotificationCategory(
            identifier: "VITAL_REMINDER",
            actions: [recordVitalAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            medicationCategory,
            appointmentCategory,
            refillCategory,
            vitalCategory
        ])
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        // Handle different actions
        switch actionIdentifier {
        case "TAKE_MEDICATION":
            handleTakeMedication(userInfo: userInfo)
        case "SKIP_MEDICATION":
            handleSkipMedication(userInfo: userInfo)
        case "VIEW_APPOINTMENT":
            handleViewAppointment(userInfo: userInfo)
        case "RECORD_VITAL":
            handleRecordVital(userInfo: userInfo)
        default:
            break
        }

        completionHandler()
    }

    private func handleTakeMedication(userInfo: [AnyHashable: Any]) {
        guard let medicationId = userInfo["medicationId"] as? String else { return }
        // Post notification to update UI
        NotificationCenter.default.post(
            name: .medicationTaken,
            object: nil,
            userInfo: ["medicationId": medicationId]
        )
    }

    private func handleSkipMedication(userInfo: [AnyHashable: Any]) {
        guard let medicationId = userInfo["medicationId"] as? String else { return }
        NotificationCenter.default.post(
            name: .medicationSkipped,
            object: nil,
            userInfo: ["medicationId": medicationId]
        )
    }

    private func handleViewAppointment(userInfo: [AnyHashable: Any]) {
        guard let appointmentId = userInfo["appointmentId"] as? String else { return }
        NotificationCenter.default.post(
            name: .viewAppointment,
            object: nil,
            userInfo: ["appointmentId": appointmentId]
        )
    }

    private func handleRecordVital(userInfo: [AnyHashable: Any]) {
        guard let vitalType = userInfo["vitalType"] as? String else { return }
        NotificationCenter.default.post(
            name: .recordVital,
            object: nil,
            userInfo: ["vitalType": vitalType]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let medicationTaken = Notification.Name("medicationTaken")
    static let medicationSkipped = Notification.Name("medicationSkipped")
    static let viewAppointment = Notification.Name("viewAppointment")
    static let recordVital = Notification.Name("recordVital")
}
