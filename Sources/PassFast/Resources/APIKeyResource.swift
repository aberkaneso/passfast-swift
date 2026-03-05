import Foundation

/// Manages API keys — list, create, revoke, delete.
public struct APIKeyResource: Sendable {
    let http: HTTPClient

    /// List all API keys.
    public func list() async throws -> [ApiKey] {
        try await http.request(method: "GET", path: "/manage-keys")
    }

    /// Create a new API key. The raw key is only returned once.
    public func create(_ request: CreateApiKeyRequest) async throws -> ApiKeyCreated {
        try await http.request(method: "POST", path: "/manage-keys", body: request)
    }

    /// Revoke an API key (sets is_active to false).
    public func revoke(_ keyId: String) async throws -> RevokeApiKeyResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(keyId)
        return try await http.request(
            method: "PATCH",
            path: "/manage-keys/\(safeId)",
            body: RevokeKeyBody()
        )
    }

    /// Permanently delete an API key.
    public func delete(_ keyId: String) async throws -> DeleteApiKeyResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(keyId)
        return try await http.request(method: "DELETE", path: "/manage-keys/\(safeId)")
    }
}

private struct RevokeKeyBody: Encodable {
    let isActive = false

    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
    }
}
