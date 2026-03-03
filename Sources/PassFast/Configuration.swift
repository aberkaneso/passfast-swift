import Foundation

/// Configuration for the PassFast client.
public struct Configuration: Sendable {
    public let baseURL: URL
    public let apiKey: String
    public let orgId: String?
    public let appId: String?
    public let timeoutInterval: TimeInterval

    static let defaultBaseURL = URL(string: "https://fbscxchawurdbieuowdi.supabase.co/functions/v1")!

    public init(
        apiKey: String,
        baseURL: URL? = nil,
        orgId: String? = nil,
        appId: String? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL ?? Self.defaultBaseURL
        self.orgId = orgId
        self.appId = appId
        self.timeoutInterval = timeoutInterval
    }
}
