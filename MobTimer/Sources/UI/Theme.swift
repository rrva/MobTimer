import SwiftUI

enum AppTheme: String, Codable, CaseIterable, Sendable {
    case mint
    case ocean
    case sunset
    
    var displayName: String {
        switch self {
        case .mint: return "Mint (Default)"
        case .ocean: return "Ocean Blue"
        case .sunset: return "Sunset Orange"
        }
    }
}

struct Theme {
    static let shared = Theme()
    
    // MARK: - Colors
    
    struct Colors {
        static func primary(for theme: AppTheme) -> Color {
            switch theme {
            case .mint: return .green
            case .ocean: return .blue
            case .sunset: return .orange
            }
        }
        
        static func secondary(for theme: AppTheme) -> Color {
            switch theme {
            case .mint: return .indigo
            case .ocean: return .purple
            case .sunset: return .red
            }
        }
        
        static func warning(for theme: AppTheme) -> Color {
            switch theme {
            case .mint: return .orange
            case .ocean: return .yellow
            case .sunset: return .purple
            }
        }
        
        static let destructive = Color.red
        static let background = Color(nsColor: .windowBackgroundColor)
        static let secondaryBackground = Color(nsColor: .controlBackgroundColor)
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        static func primary(for theme: AppTheme) -> LinearGradient {
            switch theme {
            case .mint:
                return LinearGradient(
                    colors: [.green, .mint],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ocean:
                return LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .sunset:
                return LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        static func primaryAngular(for theme: AppTheme) -> AngularGradient {
            switch theme {
            case .mint:
                return AngularGradient(gradient: Gradient(colors: [.green, .mint, .teal, .green]), center: .center)
            case .ocean:
                return AngularGradient(gradient: Gradient(colors: [.blue, .cyan, .teal, .blue]), center: .center)
            case .sunset:
                return AngularGradient(gradient: Gradient(colors: [.orange, .pink, .purple, .orange]), center: .center)
            }
        }
        
        static func rotationWindowBg(for theme: AppTheme) -> LinearGradient {
            switch theme {
            case .mint:
                return LinearGradient(
                    colors: [Color.green.opacity(0.15), Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ocean:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1), Color.pink.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .sunset:
                return LinearGradient(
                    colors: [Color.orange.opacity(0.15), Color.red.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    // MARK: - Metrics
    
    struct Metrics {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let iconSize: CGFloat = 20
    }
    
    // MARK: - Styles
    
    struct ButtonStyles {
        static let pill = Capsule()
    }
}
