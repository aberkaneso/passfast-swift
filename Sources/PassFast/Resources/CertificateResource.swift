import Foundation

/// Manages certificates — upload, list, delete.
public struct CertificateResource: Sendable {
    let http: HTTPClient

    /// Upload a single PEM certificate.
    public func upload(_ request: UploadCertificateRequest) async throws -> Certificate {
        try await http.request(method: "POST", path: "/manage-certs", body: request)
    }

    /// Upload a P12 certificate bundle.
    public func uploadP12(_ request: UploadP12Request) async throws -> UploadP12Response {
        try await http.request(method: "POST", path: "/manage-certs/p12", body: request)
    }

    /// List all certificates.
    public func list() async throws -> [Certificate] {
        try await http.request(method: "GET", path: "/manage-certs")
    }

    /// Delete a certificate by ID.
    public func delete(_ certId: String) async throws {
        try await http.request(method: "DELETE", path: "/manage-certs/\(certId)") as Void
    }
}
