import Foundation

/// Manages certificates — upload, list, delete.
public struct CertificateResource: Sendable {
    let http: HTTPClient

    /// Maximum allowed size for base64 certificate data (5 MB).
    public static let maxBase64Size = 5 * 1024 * 1024

    /// Upload a single PEM certificate.
    public func upload(_ request: UploadCertificateRequest) async throws -> Certificate {
        guard !request.certData.isEmpty else {
            throw PassFastError.validation("Certificate data must not be empty.", details: nil)
        }
        guard request.certData.count <= Self.maxBase64Size else {
            throw PassFastError.validation("Certificate data exceeds maximum size of \(Self.maxBase64Size) bytes.", details: nil)
        }
        return try await http.request(method: "POST", path: "/manage-certs", body: request)
    }

    /// Upload a P12 certificate bundle.
    public func uploadP12(_ request: UploadP12Request) async throws -> UploadP12Response {
        guard !request.p12Data.isEmpty else {
            throw PassFastError.validation("P12 data must not be empty.", details: nil)
        }
        guard request.p12Data.count <= Self.maxBase64Size else {
            throw PassFastError.validation("P12 data exceeds maximum size of \(Self.maxBase64Size) bytes.", details: nil)
        }
        guard Data(base64Encoded: request.p12Data) != nil else {
            throw PassFastError.validation("P12 data is not valid base64.", details: nil)
        }
        return try await http.request(method: "POST", path: "/manage-certs/p12", body: request)
    }

    /// List all certificates.
    public func list() async throws -> [Certificate] {
        try await http.request(method: "GET", path: "/manage-certs")
    }

    /// Delete a certificate by ID.
    public func delete(_ certId: String) async throws {
        let safeId = try RequestBuilder.sanitizePathComponent(certId)
        try await http.request(method: "DELETE", path: "/manage-certs/\(safeId)") as Void
    }
}
