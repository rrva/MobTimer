import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Participant: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    var name: String
    var isAway: Bool

    init(id: UUID = UUID(), name: String, isAway: Bool = false) {
        self.id = id
        self.name = name
        self.isAway = isAway
    }
}

extension Participant: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .participant)
    }
}

extension UTType {
    static var participant: UTType {
        UTType(exportedAs: "com.mobtimer.participant")
    }
}
