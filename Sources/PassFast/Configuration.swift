import Foundation

/// Configuration for the PassFast client.
public struct Configuration: Sendable {
    let baseURL: URL
    public let apiKey: String
    public let orgId: String?
    public let appId: String?
    public let timeoutInterval: TimeInterval

    static let defaultBaseURL = URL(string: "https://fbscxchawurdbieuowdi.supabase.co/functions/v1")!

    /// Create a configuration for the PassFast client.
    ///
    /// - Parameters:
    ///   - apiKey: Your API key.
    ///   - orgId: Organization ID.
    ///   - appId: App ID.
    ///   - timeoutInterval: Request timeout in seconds.
    public init(
        apiKey: String,
        orgId: String? = nil,
        appId: String? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self.apiKey = apiKey
        self.baseURL = Self.defaultBaseURL
        self.orgId = orgId
        self.appId = appId
        self.timeoutInterval = timeoutInterval
    }

    /// Internal initializer that accepts a custom base URL for testing.
    init(
        apiKey: String,
        baseURL: URL,
        orgId: String? = nil,
        appId: String? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.orgId = orgId
        self.appId = appId
        self.timeoutInterval = timeoutInterval
    }
}
