import Foundation

/// Manages API keys — list, create, revoke.
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

    /// Revoke (delete) an API key.
    public func revoke(_ keyId: String) async throws {
        try await http.request(method: "DELETE", path: "/manage-keys/\(keyId)") as Void
    }
}
