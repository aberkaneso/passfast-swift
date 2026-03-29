import Foundation

/// Main entry point for the PassFast SDK.
///
/// ```swift
/// let client = PassFastClient(apiKey: "pk_live_...")
/// let (pass, passId) = try await client.passes.generatePKPass(.init(
///     templateId: "...",
///     serialNumber: "MBR-001",
///     data: ["name": "Jane Doe"]
/// ))
/// ```
public final class PassFastClient: Sendable {
    /// Pass generation, listing, updating, voiding, downloading.
    public let passes: PassResource
    /// Webhook event delivery history.
    public let webhookEvents: WebhookEventResource

    /// Create a PassFast client with an API key.
    ///
    /// - Parameters:
    ///   - apiKey: Your `sk_live_` (server) or `pk_live_` (client) API key.
    ///   - orgId: Organization ID. Required for JWT auth, optional for API keys.
    ///   - appId: App ID. Required if the org has multiple apps.
    ///   - timeoutInterval: Request timeout in seconds. Defaults to 30.
    public init(
        apiKey: String,
        orgId: String? = nil,
        appId: String? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        let config = Configuration(
            apiKey: apiKey,
            orgId: orgId,
            appId: appId,
            timeoutInterval: timeoutInterval
        )
        let http = HTTPClient(configuration: config)

        self.passes = PassResource(http: http)
        self.webhookEvents = WebhookEventResource(http: http)
    }
}
