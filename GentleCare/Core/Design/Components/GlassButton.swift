//
//  GlassButton.swift
//  GentleCare
//
//  Liquid Glass button component with elderly-friendly sizing
//

import SwiftUI

// MARK: - Glass Button

struct GlassButton: View {

    // MARK: - Configuration

    enum Style {
        case primary
        case secondary
        case tertiary
        case destructive
        case success

        var backgroundColor: Color {
            switch self {
            case .primary: return Color(hex: "4A90D9")
            case .secondary: return Color.white.opacity(0.1)
            case .tertiary: return Color.clear
            case .destructive: return Color(hex: "FF6B6B")
            case .success: return Color(hex: "34C759")
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive, .success: return .white
            case .secondary, .tertiary: return .white
            }
        }

        var useGlass: Bool {
            switch self {
            case .secondary, .tertiary: return true
            default: return false
            }
        }
    }

    enum Size {
        case small
        case medium
        case large
        case extraLarge

        var height: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 56
            case .large: return 64
            case .extraLarge: return 72
            }
        }

        var font: Font {
            switch self {
            case .small: return GCTypography.buttonSmall
            case .medium: return GCTypography.buttonMedium
            case .large: return GCTypography.buttonLarge
            case .extraLarge: return GCTypography.buttonLarge
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 22
            case .large: return 26
            case .extraLarge: return 30
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            case .extraLarge: return 28
            }
        }
    }

    // MARK: - Properties

    let title: String
    let icon: String?
    let style: Style
    let size: Size
    let isFullWidth: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let haptic: GCHaptic
    let action: () -> Void

    @State private var isPressed = false

    // MARK: - Initialization

    init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        size: Size = .large,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        haptic: GCHaptic = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.haptic = haptic
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button {
            guard !isLoading && !isDisabled else { return }
            haptic.trigger()
            action()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.9)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }

                Text(title)
                    .font(size.font)
            }
            .foregroundStyle(style.foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background {
                if style.useGlass {
                    RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                        .fill(.ultraThinMaterial)
                        .glassEffect()
                } else {
                    RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                        .fill(style.backgroundColor)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .opacity(isDisabled ? 0.5 : 1.0)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(GentleCareTheme.Animation.spring, value: isPressed)
        }
        .disabled(isLoading || isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Cargando" : "")
        .accessibilityAddTraits(isDisabled ? .isButton : [.isButton])
    }
}

// MARK: - Icon Button

struct GlassIconButton: View {

    let icon: String
    let size: CGFloat
    let style: GlassButton.Style
    let haptic: GCHaptic
    let action: () -> Void

    @State private var isPressed = false

    init(
        icon: String,
        size: CGFloat = 56,
        style: GlassButton.Style = .secondary,
        haptic: GCHaptic = .light,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.haptic = haptic
        self.action = action
    }

    var body: some View {
        Button {
            haptic.trigger()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(style.foregroundColor)
                .frame(width: size, height: size)
                .background {
                    if style.useGlass {
                        Circle()
                            .fill(.ultraThinMaterial)
                    } else {
                        Circle()
                            .fill(style.backgroundColor)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(GentleCareTheme.Animation.spring, value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {

    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            GCHaptic.medium.trigger()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .fill(Color(hex: "4A90D9"))
                }
                .shadow(color: Color(hex: "4A90D9").opacity(0.4), radius: 12, x: 0, y: 6)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .animation(GentleCareTheme.Animation.spring, value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1C1C1E")
            .ignoresSafeArea()

        VStack(spacing: 20) {
            GlassButton("Tomar Medicamento", icon: "pills.fill", style: .primary, size: .extraLarge) {
                print("Primary tapped")
            }

            GlassButton("Agregar Recordatorio", icon: "bell.fill", style: .secondary, size: .large) {
                print("Secondary tapped")
            }

            GlassButton("Cancelar", style: .tertiary, size: .medium) {
                print("Tertiary tapped")
            }

            GlassButton("Eliminar", icon: "trash.fill", style: .destructive, size: .large) {
                print("Destructive tapped")
            }

            GlassButton("Confirmar Toma", icon: "checkmark", style: .success, size: .large) {
                print("Success tapped")
            }

            GlassButton("Cargando...", style: .primary, size: .large, isLoading: true) {}

            GlassButton("Deshabilitado", style: .primary, size: .large, isDisabled: true) {}

            HStack(spacing: 16) {
                GlassIconButton(icon: "phone.fill", style: .primary) {}
                GlassIconButton(icon: "message.fill", style: .secondary) {}
                GlassIconButton(icon: "video.fill", style: .secondary) {}
                FloatingActionButton(icon: "plus") {}
            }
        }
        .padding()
    }
}
