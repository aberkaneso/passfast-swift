import Foundation

/// Manages organization settings and apps.
public struct OrganizationResource: Sendable {
    let http: HTTPClient

    /// Get organization settings.
    public func get() async throws -> Organization {
        try await http.request(method: "GET", path: "/manage-org")
    }

    /// Update organization settings.
    public func update(_ request: UpdateOrgRequest) async throws -> Organization {
        try await http.request(method: "PATCH", path: "/manage-org", body: request)
    }

    /// List all apps in the organization.
    public func listApps() async throws -> [App] {
        try await http.request(method: "GET", path: "/manage-org/apps")
    }

    /// Create a new app.
    public func createApp(_ request: CreateAppRequest) async throws -> App {
        try await http.request(method: "POST", path: "/manage-org/apps", body: request)
    }

    /// Update an app. Returns `webhookSecretRaw` if `regenerateWebhookSecret` is true.
    public func updateApp(_ appId: String, _ request: UpdateAppRequest) async throws -> UpdateAppResponse {
        try await http.request(method: "PATCH", path: "/manage-org/apps/\(appId)", body: request)
    }

    /// Delete an app.
    public func deleteApp(_ appId: String) async throws {
        try await http.request(method: "DELETE", path: "/manage-org/apps/\(appId)") as Void
    }

    /// Test the configured validation webhook.
    public func testWebhook() async throws -> TestWebhookResponse {
        try await http.request(method: "POST", path: "/manage-org/app/test-webhook")
    }
}
