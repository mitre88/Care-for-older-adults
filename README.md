# GentleCare

Tu companero de cuidado con inteligencia artificial para adultos mayores.

## Descripcion

GentleCare es una aplicacion iOS nativa disenada para ayudar a cuidadores y adultos mayores a gestionar su salud de manera integral. Utiliza un sistema de IA hibrido que combina Apple Intelligence (procesamiento on-device) con OpenAI para proporcionar asistencia personalizada.

## Caracteristicas

### Control de Medicamentos
- Seguimiento de medicamentos con horarios programados
- Recordatorios inteligentes para tomas
- Alertas de recarga cuando el stock es bajo
- Historial completo de dosis

### Signos Vitales
- Registro de presion arterial, frecuencia cardiaca, glucosa, oxigeno, temperatura y peso
- Visualizacion con graficos y tendencias
- Estados de normalidad con indicadores visuales

### Citas Medicas
- Gestion de citas con doctores
- Recordatorios antes de cada cita
- Instrucciones de preparacion
- Integracion con calendario

### Asistente IA Hibrido
- Respuestas personalizadas basadas en el perfil del usuario
- Procesamiento on-device para datos sensibles (Apple Intelligence)
- Capacidades avanzadas via cloud (OpenAI) para consultas complejas
- Sugerencias contextuales

### Emergencias
- Boton SOS para llamadas de emergencia
- Contactos de emergencia con acceso rapido
- Servicios de emergencia locales

## Requisitos

- iOS 18.0+
- iPhone con chip A14 Bionic o posterior (recomendado para Apple Intelligence)
- Xcode 16.0+
- Swift 6.0

## Instalacion

1. Clona el repositorio:
```bash
git clone https://github.com/mitre88/Care-for-older-adults.git
```

2. Genera el proyecto de Xcode (requiere XcodeGen):
```bash
cd Care-for-older-adults
xcodegen generate
```

3. Abre el proyecto en Xcode:
```bash
open GentleCare.xcodeproj
```

4. Configura tu Team ID en Signing & Capabilities

5. Compila y ejecuta en un simulador o dispositivo

## Estructura del Proyecto

```
GentleCare/
├── App/                    # Entry point y ContentView
├── Core/
│   ├── Design/            # Sistema de diseno Liquid Glass
│   │   ├── Theme/         # Colores, tipografia, espaciado
│   │   ├── Components/    # GlassCard, GlassButton, etc.
│   │   └── Modifiers/     # GlassEffect modifier
│   ├── Extensions/        # Extensiones comunes
│   └── Utilities/         # NotificationManager
├── Data/
│   └── SwiftData/         # Modelos y configuracion
│       └── Models/        # ElderlyProfile, Medication, etc.
├── Features/
│   ├── Dashboard/         # Vista principal
│   ├── Onboarding/        # Flujo inicial
│   ├── Medication/        # Modulo de medicamentos
│   ├── VitalSigns/        # Modulo de signos vitales
│   ├── Appointments/      # Modulo de citas
│   ├── AIChat/            # Chat con IA hibrida
│   ├── Emergency/         # SOS y contactos
│   └── Settings/          # Configuracion
├── Navigation/            # AppTabView
└── Resources/             # Assets y localizacion
```

## Arquitectura

- **SwiftUI** para la interfaz de usuario
- **SwiftData** para persistencia local
- **MVVM** con @Observable para manejo de estado
- **IA Hibrida**:
  - Apple Intelligence para consultas simples y datos sensibles
  - OpenAI para consultas complejas y soporte emocional

## Sistema de Diseno

GentleCare utiliza el estilo **Liquid Glass** de iOS 26:
- Fondos con efecto de vidrio difuminado
- Sombras sutiles con resplandor
- Animaciones con spring para interacciones
- Targets tactiles minimos de 60pt para accesibilidad

## Privacidad

- Todos los datos de salud se almacenan localmente
- No se utiliza CloudKit
- Las consultas sensibles se procesan on-device
- API keys almacenadas en Keychain

## Localizacion

Idiomas soportados:
- Espanol (principal)
- English
- Francais

## Licencia

Este proyecto es privado y de uso personal.

## Autor

Desarrollado con amor para el cuidado de nuestros mayores.

---

*Version 1.0.0*
