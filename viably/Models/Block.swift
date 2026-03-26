import Foundation

struct Block: Codable, Identifiable {
    let id: UUID
    let blockerID: UUID
    let blockedID: UUID
    let createdAt: Date
}
