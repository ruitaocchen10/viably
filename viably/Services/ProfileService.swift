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

    static func upsert(_ profile: Profile) async throws -> Profile {
        try await supabase
            .from("profiles")
            .upsert(profile)
            .single()
            .execute()
            .value
    }
}
