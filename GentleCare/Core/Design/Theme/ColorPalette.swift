//
//  ColorPalette.swift
//  GentleCare
//
//  Elderly-friendly color palette with high contrast
//

import SwiftUI

// MARK: - Color Extensions

extension Color {

    // MARK: - Primary Colors

    /// Primary blue - calming and trustworthy
    static let gcPrimary = Color("gcPrimary")

    /// Secondary green - hope and health
    static let gcSecondary = Color("gcSecondary")

    /// Accent coral - warm and attention-grabbing
    static let gcAccent = Color("gcAccent")

    // MARK: - Background Colors

    /// Main background - dark gray
    static let gcBackground = Color("gcBackground")

    /// Elevated surface - slightly lighter
    static let gcSurface = Color("gcSurface")

    /// Card background with glass effect
    static let gcCard = Color("gcCard")

    // MARK: - Text Colors

    /// Primary text - white
    static let gcTextPrimary = Color("gcTextPrimary")

    /// Secondary text - light gray
    static let gcTextSecondary = Color("gcTextSecondary")

    /// Tertiary text - dimmed
    static let gcTextTertiary = Color("gcTextTertiary")

    // MARK: - Semantic Colors

    /// Success - bright green
    static let gcSuccess = Color("gcSuccess")

    /// Warning - amber
    static let gcWarning = Color("gcWarning")

    /// Error - soft red
    static let gcError = Color("gcError")

    /// Info - sky blue
    static let gcInfo = Color("gcInfo")

    // MARK: - Vital Signs Colors

    static let vitalBP = Color("vitalBP")
    static let vitalHR = Color("vitalHR")
    static let vitalO2 = Color("vitalO2")
    static let vitalTemp = Color("vitalTemp")
    static let vitalGlucose = Color("vitalGlucose")
    static let vitalWeight = Color("vitalWeight")
    static let vitalRespiratory = Color("vitalRespiratory")

    static let vitalLow = Color("vitalLow")
    static let vitalNormal = Color("vitalNormal")
    static let vitalHigh = Color("vitalHigh")

    // MARK: - Medication Colors

    static let medicationWhite = Color.white
    static let medicationBlue = Color.blue
    static let medicationPink = Color.pink
    static let medicationYellow = Color.yellow
    static let medicationOrange = Color.orange
    static let medicationRed = Color.red
    static let medicationGreen = Color.green
    static let medicationPurple = Color.purple
    static let medicationBrown = Color.brown
    static let medicationBeige = Color(red: 0.96, green: 0.87, blue: 0.70)

    // MARK: - Glass Effect Colors

    /// Glass tint for overlays
    static let gcGlassTint = Color.white.opacity(0.1)

    /// Glass border
    static let gcGlassBorder = Color.white.opacity(0.2)

    /// Glass highlight
    static let gcGlassHighlight = Color.white.opacity(0.3)
}

// MARK: - Hex Color Definitions

/*
 Color Palette Reference (for Assets.xcassets):

 gcPrimary:          #4A90D9 (Calming Blue)
 gcSecondary:        #5BB381 (Hope Green)
 gcAccent:           #E8846B (Warm Coral)

 gcBackground:       #1C1C1E (Dark Gray)
 gcSurface:          #2C2C2E (Elevated Gray)
 gcCard:             #3A3A3C (Card Gray)

 gcTextPrimary:      #FFFFFF (White)
 gcTextSecondary:    #8E8E93 (Light Gray)
 gcTextTertiary:     #636366 (Dimmed Gray)

 gcSuccess:          #34C759 (Bright Green)
 gcWarning:          #FFB340 (Amber)
 gcError:            #FF6B6B (Soft Red)
 gcInfo:             #5AC8FA (Sky Blue)

 vitalBP:            #FF6B6B (Red)
 vitalHR:            #FF2D55 (Pink Red)
 vitalO2:            #5AC8FA (Sky Blue)
 vitalTemp:          #FF9500 (Orange)
 vitalGlucose:       #AF52DE (Purple)
 vitalWeight:        #30D158 (Green)
 vitalRespiratory:   #64D2FF (Cyan)

 vitalLow:           #5AC8FA (Blue - Low)
 vitalNormal:        #34C759 (Green - Normal)
 vitalHigh:          #FF6B6B (Red - High)
*/

// MARK: - Color from Hex

extension Color {

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fallback Colors (when assets not available)

extension Color {

    static let gcPrimaryFallback = Color(hex: "4A90D9")
    static let gcSecondaryFallback = Color(hex: "5BB381")
    static let gcAccentFallback = Color(hex: "E8846B")
    static let gcBackgroundFallback = Color(hex: "1C1C1E")
    static let gcSurfaceFallback = Color(hex: "2C2C2E")
    static let gcSuccessFallback = Color(hex: "34C759")
    static let gcWarningFallback = Color(hex: "FFB340")
    static let gcErrorFallback = Color(hex: "FF6B6B")
}

// MARK: - Gradient Definitions

extension LinearGradient {

    static let gcPrimaryGradient = LinearGradient(
        colors: [Color(hex: "4A90D9"), Color(hex: "6BA3E0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gcSecondaryGradient = LinearGradient(
        colors: [Color(hex: "5BB381"), Color(hex: "7BC49A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gcAccentGradient = LinearGradient(
        colors: [Color(hex: "E8846B"), Color(hex: "F0A08C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gcGlassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.15),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gcGlassBorderGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.3),
            Color.white.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
