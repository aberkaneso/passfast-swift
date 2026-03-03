import Foundation

/// Manages images — upload, list, delete.
public struct ImageResource: Sendable {
    let http: HTTPClient

    /// Upload a base64-encoded image.
    public func upload(_ request: UploadImageRequest) async throws -> PassImage {
        try await http.request(method: "POST", path: "/manage-images", body: request)
    }

    /// List all images.
    public func list() async throws -> [PassImage] {
        try await http.request(method: "GET", path: "/manage-images")
    }

    /// Delete an image by ID.
    public func delete(_ imageId: String) async throws {
        try await http.request(method: "DELETE", path: "/manage-images/\(imageId)") as Void
    }
}
