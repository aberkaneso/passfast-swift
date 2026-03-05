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
    /// Template CRUD and publishing.
    public let templates: TemplateResource
    /// Image listing and deletion.
    public let images: ImageResource
    /// Certificate listing and deletion.
    public let certificates: CertificateResource
    /// Organization settings and app management.
    public let organization: OrganizationResource
    /// API key management.
    public let apiKeys: APIKeyResource
    /// Member and invitation management.
    public let members: MemberResource
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
        self.templates = TemplateResource(http: http)
        self.images = ImageResource(http: http)
        self.certificates = CertificateResource(http: http)
        self.organization = OrganizationResource(http: http)
        self.apiKeys = APIKeyResource(http: http)
        self.members = MemberResource(http: http, orgId: config.orgId)
        self.webhookEvents = WebhookEventResource(http: http)
    }
}
