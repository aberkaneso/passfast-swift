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

    /// Get the current app details.
    public func getApp() async throws -> App {
        try await http.request(method: "GET", path: "/manage-org/app")
    }

    /// List all apps in the organization.
    public func listApps() async throws -> [App] {
        try await http.request(method: "GET", path: "/manage-org/app")
    }

    /// Create a new app.
    public func createApp(_ request: CreateAppRequest) async throws -> App {
        try await http.request(method: "POST", path: "/manage-org/app", body: request)
    }

    /// Update an app. Returns `webhookSecretRaw` if `regenerateWebhookSecret` is true.
    public func updateApp(_ request: UpdateAppRequest) async throws -> UpdateAppResponse {
        try await http.request(method: "PATCH", path: "/manage-org/app", body: request)
    }

    /// Delete an app.
    public func deleteApp() async throws {
        try await http.request(method: "DELETE", path: "/manage-org/app") as Void
    }

    /// Test the configured validation webhook.
    public func testWebhook() async throws -> TestWebhookResponse {
        try await http.request(method: "POST", path: "/manage-org/app/test-webhook")
    }
}
