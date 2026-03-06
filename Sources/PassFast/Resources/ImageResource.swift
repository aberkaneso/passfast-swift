import Foundation

/// Manages images — upload, list, delete.
public struct ImageResource: Sendable {
    let http: HTTPClient

    /// Maximum allowed file size for image upload (10 MB).
    public static let maxFileSize = 10 * 1024 * 1024

    /// Upload an image as multipart/form-data.
    public func upload(_ request: UploadImageRequest) async throws -> PassImage {
        guard !request.fileData.isEmpty else {
            throw PassFastError.validation("Image data must not be empty.", details: nil)
        }
        guard request.fileData.count <= Self.maxFileSize else {
            throw PassFastError.validation("Image data exceeds maximum size of \(Self.maxFileSize) bytes.", details: nil)
        }
        return try await http.requestMultipart(
            path: "/manage-images",
            fields: ["purpose": request.purpose.rawValue],
            fileData: request.fileData,
            fileFieldName: "file",
            fileName: request.fileName ?? "image"
        )
    }

    /// List all images.
    public func list() async throws -> [PassImage] {
        try await http.request(method: "GET", path: "/manage-images")
    }

    /// Delete an image by ID.
    public func delete(_ imageId: String) async throws -> DeleteImageResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(imageId)
        return try await http.request(method: "DELETE", path: "/manage-images/\(safeId)")
    }
}
