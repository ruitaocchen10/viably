//
//  SupabaseClient.swift
//  viably
//

import Foundation
import Supabase

private let postgresDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        // TIMESTAMPTZ: "2024-01-15T10:30:00.123456+00:00"
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: string) { return date }

        // TIMESTAMP: "2024-01-15T10:30:00Z"
        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        if let date = basic.date(from: string) { return date }

        // DATE: "2024-01-15"
        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = .current
        if let date = dateOnly.date(from: string) { return date }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(string)")
    }
    return decoder
}()

private func config(_ key: String) -> String {
    guard let value = Bundle.main.infoDictionary?[key] as? String, !value.isEmpty else {
        fatalError("Missing required config key '\(key)' — check Config.xcconfig")
    }
    return value
}

private func makeSupabaseClient() -> SupabaseClient {
    let urlString = "https://\(config("SUPABASE_HOST"))"
    guard let url = URL(string: urlString) else {
        preconditionFailure("Invalid Supabase URL: \(urlString)")
    }
    return SupabaseClient(
        supabaseURL: url,
        supabaseKey: config("SUPABASE_ANON_KEY"),
        options: SupabaseClientOptions(
            db: SupabaseClientOptions.DatabaseOptions(decoder: postgresDecoder)
        )
    )
}

let supabase = makeSupabaseClient()
