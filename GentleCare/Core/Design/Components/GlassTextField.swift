//
//  GlassTextField.swift
//  GentleCare
//
//  Liquid Glass text input component for elderly users
//

import SwiftUI

// MARK: - Glass Text Field

struct GlassTextField: View {

    // MARK: - Properties

    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let isMultiline: Bool
    let errorMessage: String?

    @FocusState private var isFocused: Bool
    @State private var showSecureText = false

    // MARK: - Initialization

    init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        isMultiline: Bool = false,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.isMultiline = isMultiline
        self.errorMessage = errorMessage
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(title)
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.8))

            // Input field
            HStack(spacing: 12) {
                // Icon
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isFocused ? Color(hex: "4A90D9") : .white.opacity(0.5))
                        .frame(width: 24)
                }

                // Text input
                if isMultiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...6)
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white)
                        .focused($isFocused)
                } else if isSecure && !showSecureText {
                    SecureField(placeholder, text: $text)
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white)
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                        .autocorrectionDisabled(keyboardType != .default)
                        .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .sentences)
                }

                // Secure toggle
                if isSecure {
                    Button {
                        showSecureText.toggle()
                    } label: {
                        Image(systemName: showSecureText ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                // Clear button
                if !text.isEmpty && !isSecure {
                    Button {
                        text = ""
                        GCHaptic.light.trigger()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 60)
            .background {
                RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                    .stroke(
                        isFocused ? Color(hex: "4A90D9") :
                        errorMessage != nil ? Color(hex: "FF6B6B") :
                        Color.white.opacity(0.2),
                        lineWidth: isFocused ? 2 : 1
                    )
            }
            .animation(GentleCareTheme.Animation.spring, value: isFocused)

            // Error message
            if let errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(GCTypography.captionMedium)
                }
                .foregroundStyle(Color(hex: "FF6B6B"))
            }
        }
    }
}

// MARK: - Numeric Input

struct GlassNumericInput: View {

    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let icon: String?

    init(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1,
        unit: String = "",
        icon: String? = nil
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.unit = unit
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 16) {
                // Decrease button
                Button {
                    if value > range.lowerBound {
                        value = max(range.lowerBound, value - step)
                        GCHaptic.light.trigger()
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        }
                }
                .disabled(value <= range.lowerBound)
                .opacity(value <= range.lowerBound ? 0.5 : 1)

                // Value display
                VStack(spacing: 4) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundStyle(Color(hex: "4A90D9"))
                    }

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(formattedValue)
                            .font(GCTypography.numericMedium)
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        if !unit.isEmpty {
                            Text(unit)
                                .font(GCTypography.labelMedium)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .glassEffect(style: .subtle, cornerRadius: GentleCareTheme.CornerRadius.md)

                // Increase button
                Button {
                    if value < range.upperBound {
                        value = min(range.upperBound, value + step)
                        GCHaptic.light.trigger()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background {
                            Circle()
                                .fill(Color(hex: "4A90D9"))
                        }
                }
                .disabled(value >= range.upperBound)
                .opacity(value >= range.upperBound ? 0.5 : 1)
            }
        }
    }

    private var formattedValue: String {
        if step >= 1 {
            return String(format: "%.0f", value)
        } else if step >= 0.1 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}

// MARK: - Date Picker

struct GlassDatePicker: View {

    let title: String
    @Binding var date: Date
    let displayedComponents: DatePickerComponents

    init(
        _ title: String,
        date: Binding<Date>,
        displayedComponents: DatePickerComponents = .date
    ) {
        self.title = title
        self._date = date
        self.displayedComponents = displayedComponents
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.8))

            DatePicker("", selection: $date, displayedComponents: displayedComponents)
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Color(hex: "4A90D9"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

// MARK: - Preview

#Preview("GlassTextField Components") {
    ZStack {
        Color(hex: "1C1C1E")
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 24) {
                GlassTextField(
                    "Nombre",
                    placeholder: "Ingresa tu nombre",
                    text: .constant("Maria Garcia"),
                    icon: "person.fill"
                )

                GlassTextField(
                    "Email",
                    placeholder: "correo@ejemplo.com",
                    text: .constant(""),
                    icon: "envelope.fill",
                    keyboardType: .emailAddress
                )

                GlassTextField(
                    "Contrasena",
                    placeholder: "Tu contrasena",
                    text: .constant("password123"),
                    icon: "lock.fill",
                    isSecure: true
                )

                GlassTextField(
                    "Notas",
                    placeholder: "Escribe tus notas aqui...",
                    text: .constant(""),
                    icon: "note.text",
                    isMultiline: true
                )

                GlassTextField(
                    "Campo con error",
                    placeholder: "Texto invalido",
                    text: .constant("abc"),
                    icon: "exclamationmark.triangle.fill",
                    errorMessage: "Este campo es requerido"
                )

                GlassNumericInput(
                    "Dosis",
                    value: .constant(10),
                    range: 1...100,
                    step: 5,
                    unit: "mg",
                    icon: "pills.fill"
                )

                GlassDatePicker(
                    "Fecha de nacimiento",
                    date: .constant(Date()),
                    displayedComponents: .date
                )

                GlassDatePicker(
                    "Hora del recordatorio",
                    date: .constant(Date()),
                    displayedComponents: .hourAndMinute
                )
            }
            .padding()
        }
    }
}
