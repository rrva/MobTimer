import SwiftUI

struct Theme {
    static let shared = Theme()
    
    // MARK: - Colors
    
    struct Colors {
        static let primary = Color.green
        static let secondary = Color.indigo
        static let warning = Color.orange
        static let destructive = Color.red
        static let background = Color(nsColor: .windowBackgroundColor)
        static let secondaryBackground = Color(nsColor: .controlBackgroundColor)
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [.green, .mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let primaryAngular = AngularGradient(
            gradient: Gradient(colors: [.green, .mint, .teal, .green]),
            center: .center
        )
        
        static let rotationWindowBg = LinearGradient(
            colors: [
                Color.green.opacity(0.15),
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
