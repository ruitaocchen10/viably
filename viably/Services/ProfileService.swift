import Foundation
import Supabase

struct ProfileService {
    static func fetch(id: UUID) async throws -> Profile {
        try await supabase
            .from("profiles")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    private struct ProfileUpdate: Encodable {
        let username: String
        let displayName: String?
        let avatarURL: String?

        enum CodingKeys: String, CodingKey {
            case username
            case displayName = "display_name"
            case avatarURL = "avatar_url"
        }
    }

    static func update(_ profile: Profile) async throws -> Profile {
        let payload = ProfileUpdate(
            username: profile.username,
            displayName: profile.displayName,
            avatarURL: profile.avatarURL
        )
        return try await supabase
            .from("profiles")
            .update(payload)
            .eq("id", value: profile.id)
            .single()
            .execute()
            .value
    }
}
