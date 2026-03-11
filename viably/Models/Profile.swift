struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    let avatarURL: String?
    let createdAt: Date
}
