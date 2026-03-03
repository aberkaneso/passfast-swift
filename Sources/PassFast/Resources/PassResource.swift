import Foundation
#if canImport(PassKit)
import PassKit
#endif

/// Manages passes — generate, list, get, update, void, download.
public struct PassResource: Sendable {
    let http: HTTPClient

    /// Generate a .pkpass binary. Returns passId, raw pkpass data, and whether it already existed.
    public func generate(_ request: GeneratePassRequest) async throws -> GeneratePassResponse {
        let raw = try await http.requestRaw(
            method: "POST",
            path: "/generate-pass",
            body: request
        )

        let passId = raw.httpResponse.value(forHTTPHeaderField: "X-Pass-Id") ?? ""
        let existed = raw.httpResponse.value(forHTTPHeaderField: "X-Pass-Existed") == "true"

        return GeneratePassResponse(passId: passId, pkpassData: raw.data, existed: existed)
    }

    #if canImport(PassKit)
    /// Generate a pass and return a `PKPass` ready for Apple Wallet.
    public func generatePKPass(_ request: GeneratePassRequest) async throws -> (PKPass, String) {
        let response = try await generate(request)
        let pkPass = try PKPass(data: response.pkpassData)
        return (pkPass, response.passId)
    }
    #endif

    /// List passes with optional filters.
    public func list(_ params: ListPassesParams? = nil) async throws -> [Pass] {
        try await http.request(
            method: "GET",
            path: "/manage-passes",
            queryItems: params?.queryItems
        )
    }

    /// Get a single pass by ID.
    public func get(_ passId: String) async throws -> Pass {
        try await http.request(method: "GET", path: "/manage-passes/\(passId)")
    }

    /// Download the .pkpass binary for a pass.
    public func download(_ passId: String) async throws -> Data {
        let raw = try await http.requestRaw(
            method: "GET",
            path: "/manage-passes/\(passId)/download"
        )
        return raw.data
    }

    /// Update a pass (data, push_update). Triggers push notification.
    public func update(_ passId: String, _ request: UpdatePassRequest) async throws -> UpdatePassResponse {
        try await http.request(
            method: "PATCH",
            path: "/manage-passes/\(passId)",
            body: request
        )
    }

    /// Void (invalidate) a pass. Triggers push notification.
    public func void(_ passId: String) async throws -> VoidPassResponse {
        try await http.request(method: "POST", path: "/manage-passes/\(passId)/void")
    }
}
