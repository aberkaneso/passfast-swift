import Foundation

struct RequestBuilder {
    let configuration: Configuration

    func buildRequest(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil,
        additionalHeaders: [String: String]? = nil
    ) throws -> URLRequest {
        var components = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
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
