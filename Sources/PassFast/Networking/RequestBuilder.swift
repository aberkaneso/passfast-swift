import Foundation

struct RequestBuilder {
    let configuration: Configuration

    /// Percent-encodes a single path segment to prevent path traversal.
    /// Rejects IDs containing `/` or `..` even after encoding.
    static func sanitizePathComponent(_ component: String) throws -> String {
        guard !component.isEmpty else {
            throw PassFastError.validation("Path parameter must not be empty.", details: nil)
        }
        guard !component.contains("/"), !component.contains("..") else {
            throw PassFastError.validation("Path parameter contains invalid characters.", details: nil)
        }
        guard let encoded = component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw PassFastError.validation("Path parameter could not be percent-encoded.", details: nil)
        }
        return encoded
    }

    func buildRequest(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil,
        additionalHeaders: [String: String]? = nil
    ) throws -> URLRequest {
        guard var components = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw PassFastError.unknown(statusCode: 0, code: "invalid_url", message: "Failed to build URL components for \(path)")
        }
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw PassFastError.unknown(statusCode: 0, code: "invalid_url", message: "Failed to build URL for \(path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = configuration.timeoutInterval
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")

        if let orgId = configuration.orgId {
            request.setValue(orgId, forHTTPHeaderField: "X-Org-Id")
        }
        if let appId = configuration.appId {
            request.setValue(appId, forHTTPHeaderField: "X-App-Id")
        }

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }

        if let additionalHeaders {
            for (key, value) in additionalHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }
}
