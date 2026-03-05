import Foundation

/// Manages images — upload, list, delete.
public struct ImageResource: Sendable {
    let http: HTTPClient

    /// Maximum allowed size for base64 image data (10 MB).
    public static let maxBase64Size = 10 * 1024 * 1024

    /// Upload a base64-encoded image.
    public func upload(_ request: UploadImageRequest) async throws -> PassImage {
        guard !request.data.isEmpty else {
            throw PassFastError.validation("Image data must not be empty.", details: nil)
        }
        guard request.data.count <= Self.maxBase64Size else {
            throw PassFastError.validation("Image data exceeds maximum size of \(Self.maxBase64Size) bytes.", details: nil)
        }
        guard Data(base64Encoded: request.data) != nil else {
            throw PassFastError.validation("Image data is not valid base64.", details: nil)
        }
        return try await http.request(method: "POST", path: "/manage-images", body: request)
    }

    /// List all images.
    public func list() async throws -> [PassImage] {
        try await http.request(method: "GET", path: "/manage-images")
    }

    /// Delete an image by ID.
    public func delete(_ imageId: String) async throws {
        let safeId = try RequestBuilder.sanitizePathComponent(imageId)
        try await http.request(method: "DELETE", path: "/manage-images/\(safeId)") as Void
    }
}
