import Foundation

/// Lists webhook event delivery history.
public struct WebhookEventResource: Sendable {
    let http: HTTPClient

    /// List webhook events with optional filters.
    public func list(_ params: ListWebhookEventsParams? = nil) async throws -> [WebhookEvent] {
        try await http.request(
            method: "GET",
            path: "/manage-org/webhook-events",
            queryItems: params?.queryItems
        )
    }
}
