import Foundation

/// Manages certificates — list, delete.
public struct CertificateResource: Sendable {
    let http: HTTPClient

    /// List all certificates.
    public func list() async throws -> [Certificate] {
        try await http.request(method: "GET", path: "/manage-certs")
    }

    /// Delete a certificate by ID.
    public func delete(_ certId: String) async throws {
        try await http.request(method: "DELETE", path: "/manage-certs/\(certId)") as Void
    }
}
