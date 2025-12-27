//
//  OnboardingView.swift
//  GentleCare
//
//  User onboarding flow for setting up elderly profile
//

import SwiftUI
import SwiftData

struct OnboardingView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // MARK: - State

    @State private var currentStep = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -70, to: Date())!
    @State private var bloodType: BloodType?
    @State private var allergies: [String] = []
    @State private var medicalConditions: [String] = []
    @State private var newAllergy = ""
    @State private var newCondition = ""

    private let totalSteps = 4

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color(hex: "1C1C1E")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.top, GentleCareTheme.Spacing.lg)

                // Content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    personalInfoStep.tag(1)
                    healthInfoStep.tag(2)
                    confirmationStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, GentleCareTheme.Spacing.lg)
                    .padding(.bottom, GentleCareTheme.Spacing.xl)
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? Color(hex: "4A90D9") : Color.white.opacity(0.2))
                    .frame(height: 4)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .padding(.horizontal, GentleCareTheme.Spacing.lg)
    }

    // MARK: - Welcome Step

    private var welcomeStep: some View {
        VStack(spacing: GentleCareTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color(hex: "4A90D9"))
                .symbolEffect(.pulse)

            VStack(spacing: GentleCareTheme.Spacing.md) {
                Text("Bienvenido a\nGentleCare")
                    .font(GCTypography.displayMedium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Tu companero para el cuidado\nde tu ser querido")
                    .font(GCTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "pills.fill", title: "Control de medicamentos", color: Color(hex: "4A90D9"))
                FeatureRow(icon: "heart.fill", title: "Seguimiento de signos vitales", color: Color(hex: "FF6B6B"))
                FeatureRow(icon: "calendar", title: "Gestion de citas medicas", color: Color(hex: "5BB381"))
                FeatureRow(icon: "bubble.left.fill", title: "Asistente IA personalizado", color: Color(hex: "AF52DE"))
            }
            .padding(.horizontal, GentleCareTheme.Spacing.lg)

            Spacer()
        }
        .padding()
    }

    // MARK: - Personal Info Step

    private var personalInfoStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Informacion personal")
                        .font(GCTypography.headline1)
                        .foregroundStyle(.white)

                    Text("Ingresa los datos de la persona a cuidar")
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, GentleCareTheme.Spacing.xl)

                GlassTextField(
                    "Nombre",
                    placeholder: "Ingresa el nombre",
                    text: $firstName,
                    icon: "person.fill"
                )

                GlassTextField(
                    "Apellido",
                    placeholder: "Ingresa el apellido",
                    text: $lastName,
                    icon: "person.fill"
                )

                GlassDatePicker(
                    "Fecha de nacimiento",
                    date: $dateOfBirth,
                    displayedComponents: .date
                )

                // Blood type picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo de sangre (opcional)")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(BloodType.allCases) { type in
                                BloodTypeChip(
                                    type: type,
                                    isSelected: bloodType == type
                                ) {
                                    bloodType = bloodType == type ? nil : type
                                    GCHaptic.selection.trigger()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, GentleCareTheme.Spacing.lg)
        }
    }

    // MARK: - Health Info Step

    private var healthInfoStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Informacion de salud")
                        .font(GCTypography.headline1)
                        .foregroundStyle(.white)

                    Text("Agrega alergias y condiciones medicas")
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, GentleCareTheme.Spacing.xl)

                // Allergies
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alergias")
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)

                    HStack {
                        GlassTextField(
                            "",
                            placeholder: "Agregar alergia",
                            text: $newAllergy,
                            icon: "allergens"
                        )

                        GlassIconButton(icon: "plus", style: .primary) {
                            if !newAllergy.isEmpty {
                                allergies.append(newAllergy)
                                newAllergy = ""
                            }
                        }
                    }

                    FlowLayout(spacing: 8) {
                        ForEach(allergies, id: \.self) { allergy in
                            TagChip(text: allergy, color: Color(hex: "FF6B6B")) {
                                allergies.removeAll { $0 == allergy }
                            }
                        }
                    }
                }

                // Medical Conditions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Condiciones medicas")
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)

                    HStack {
                        GlassTextField(
                            "",
                            placeholder: "Agregar condicion",
                            text: $newCondition,
                            icon: "heart.text.square"
                        )

                        GlassIconButton(icon: "plus", style: .primary) {
                            if !newCondition.isEmpty {
                                medicalConditions.append(newCondition)
                                newCondition = ""
                            }
                        }
                    }

                    FlowLayout(spacing: 8) {
                        ForEach(medicalConditions, id: \.self) { condition in
                            TagChip(text: condition, color: Color(hex: "FFB340")) {
                                medicalConditions.removeAll { $0 == condition }
                            }
                        }
                    }
                }

                // Common conditions shortcuts
                VStack(alignment: .leading, spacing: 8) {
                    Text("Condiciones comunes")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.6))

                    FlowLayout(spacing: 8) {
                        ForEach(commonConditions, id: \.self) { condition in
                            Button {
                                if !medicalConditions.contains(condition) {
                                    medicalConditions.append(condition)
                                    GCHaptic.light.trigger()
                                }
                            } label: {
                                Text("+ \(condition)")
                                    .font(GCTypography.labelSmall)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background {
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    }
                            }
                            .disabled(medicalConditions.contains(condition))
                        }
                    }
                }
            }
            .padding(.horizontal, GentleCareTheme.Spacing.lg)
        }
    }

    private var commonConditions: [String] {
        ["Hipertension", "Diabetes", "Artritis", "Alzheimer", "Parkinson", "EPOC", "Insuficiencia cardiaca"]
    }

    // MARK: - Confirmation Step

    private var confirmationStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirmar datos")
                        .font(GCTypography.headline1)
                        .foregroundStyle(.white)

                    Text("Revisa la informacion antes de continuar")
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, GentleCareTheme.Spacing.xl)

                // Profile summary
                GlassCard(size: .large) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "4A90D9").opacity(0.3))
                                    .frame(width: 60, height: 60)

                                Text(initials)
                                    .font(GCTypography.headline2)
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(firstName) \(lastName)")
                                    .font(GCTypography.headline2)
                                    .foregroundStyle(.white)

                                Text("\(age) anos")
                                    .font(GCTypography.bodyMedium)
                                    .foregroundStyle(.white.opacity(0.7))
                            }

                            Spacer()

                            if let bloodType {
                                Text(bloodType.rawValue)
                                    .font(GCTypography.labelLarge)
                                    .foregroundStyle(Color(hex: "FF6B6B"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background {
                                        Capsule()
                                            .fill(Color(hex: "FF6B6B").opacity(0.2))
                                    }
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        if !allergies.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Alergias", systemImage: "allergens")
                                    .font(GCTypography.labelMedium)
                                    .foregroundStyle(.white.opacity(0.7))

                                Text(allergies.joined(separator: ", "))
                                    .font(GCTypography.bodyMedium)
                                    .foregroundStyle(.white)
                            }
                        }

                        if !medicalConditions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Condiciones", systemImage: "heart.text.square")
                                    .font(GCTypography.labelMedium)
                                    .foregroundStyle(.white.opacity(0.7))

                                Text(medicalConditions.joined(separator: ", "))
                                    .font(GCTypography.bodyMedium)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }

                // Privacy note
                GlassCard(size: .medium, glassStyle: .subtle) {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(hex: "34C759"))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tus datos estan seguros")
                                .font(GCTypography.titleSmall)
                                .foregroundStyle(.white)

                            Text("Toda la informacion se guarda solo en tu dispositivo")
                                .font(GCTypography.captionLarge)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(.horizontal, GentleCareTheme.Spacing.lg)
        }
    }

    private var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return "\(first)\(last)"
    }

    private var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                GlassButton(
                    "Atras",
                    style: .secondary,
                    isFullWidth: false
                ) {
                    withAnimation { currentStep -= 1 }
                }
            }

            GlassButton(
                currentStep == totalSteps - 1 ? "Comenzar" : "Siguiente",
                icon: currentStep == totalSteps - 1 ? "checkmark" : "arrow.right",
                style: .primary,
                isDisabled: !canProceed
            ) {
                if currentStep == totalSteps - 1 {
                    saveProfile()
                } else {
                    withAnimation { currentStep += 1 }
                }
            }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 1:
            return !firstName.isEmpty && !lastName.isEmpty
        default:
            return true
        }
    }

    // MARK: - Save Profile

    private func saveProfile() {
        let profile = ElderlyProfile(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            bloodType: bloodType,
            allergies: allergies,
            medicalConditions: medicalConditions
        )

        modelContext.insert(profile)

        do {
            try modelContext.save()
            hasCompletedOnboarding = true
            GCHaptic.success.trigger()
        } catch {
            print("Error saving profile: \(error)")
            GCHaptic.error.trigger()
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 40)

            Text(title)
                .font(GCTypography.bodyLarge)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Blood Type Chip

struct BloodTypeChip: View {
    let type: BloodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(GCTypography.labelLarge)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(hex: "FF6B6B") : Color.white.opacity(0.1))
                }
        }
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let text: String
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(color.opacity(0.3))
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .modelContainer(try! ModelContainer.createPreview())
}
