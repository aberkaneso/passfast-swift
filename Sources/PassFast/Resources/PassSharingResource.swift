import Foundation

/// Manages pass sharing — create share tokens, get metadata, download shared passes.
public struct PassSharingResource: Sendable {
    let http: HTTPClient

    /// Create a share token for a pass. Idempotent — returns existing token if already shared.
    public func createShareToken(_ request: CreateShareTokenRequest) async throws -> ShareToken {
        try await http.request(method: "POST", path: "/share-pass/create", body: request)
    }

    /// Get public metadata for a shared pass. No authentication required.
    public func getMetadata(_ token: String) async throws -> SharePassMetadata {
        let safeToken = try RequestBuilder.sanitizePathComponent(token)
        return try await http.request(method: "GET", path: "/share-pass/\(safeToken)")
    }

    /// Download the Apple .pkpass binary for a shared pass. No authentication required.
    public func download(_ token: String) async throws -> Data {
        let safeToken = try RequestBuilder.sanitizePathComponent(token)
        let raw = try await http.requestRaw(method: "GET", path: "/share-pass/\(safeToken)/download")
        return raw.data
    }
}
