import Foundation

actor IntelliJService {
    static let shared = IntelliJService()

    private let session: URLSession
    private let timeoutInterval: TimeInterval = 5.0

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval
        self.session = URLSession(configuration: config)
    }

    enum IntelliJError: Error, LocalizedError {
        case invalidURL
        case requestFailed(String)
        case keymapNotFound(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid plugin URL"
            case .requestFailed(let message):
                return "Request failed: \(message)"
            case .keymapNotFound(let name):
                return "Keymap not found: \(name)"
            }
        }
    }

    func isPluginAvailable(baseURL: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/health") else {
            return false
        }

        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }

    func fetchAvailableKeymaps(baseURL: String) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/api/keymaps") else {
            throw IntelliJError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw IntelliJError.requestFailed("Failed to fetch keymaps")
        }

        struct KeymapsResponse: Codable {
            let keymaps: [String]
        }

        let keymapsResponse = try JSONDecoder().decode(KeymapsResponse.self, from: data)
        return keymapsResponse.keymaps
    }

    func getCurrentKeymap(baseURL: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/keymap") else {
            throw IntelliJError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw IntelliJError.requestFailed("Failed to get current keymap")
        }

        struct KeymapResponse: Codable {
            let name: String
        }

        let keymapResponse = try JSONDecoder().decode(KeymapResponse.self, from: data)
        return keymapResponse.name
    }

    func setKeymap(name: String, baseURL: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/keymap") else {
            throw IntelliJError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        struct SetKeymapRequest: Codable {
            let name: String
        }

        let body = SetKeymapRequest(name: name)
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw IntelliJError.requestFailed("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            return
        case 404:
            throw IntelliJError.keymapNotFound(name)
        default:
            throw IntelliJError.requestFailed("HTTP \(httpResponse.statusCode)")
        }
    }

    static let commonKeymaps: [String] = [
        "macOS",
        "macOS System Shortcuts",
        "IntelliJ IDEA Classic",
        "Eclipse",
        "Eclipse (macOS)",
        "Visual Studio",
        "VSCode",
        "VSCode (macOS)",
        "Sublime Text",
        "Sublime Text (macOS)",
        "Emacs",
        "NetBeans"
    ]
}
