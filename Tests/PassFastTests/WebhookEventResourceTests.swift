import Testing
import Foundation
@testable import PassFast

extension AllMockTests {
    @Suite("WebhookEventResource")
    struct WebhookEventResourceTests {
        let http = makeTestHTTPClient()

        @Test func listWebhookEvents() async throws {
            let evtJSON = """
            [{
                "id": "evt-1",
                "event_type": "pass.updated", "payload": {},
                "delivery_status": "pending", "attempts": 0,
                "delivered_at": null,
                "next_retry_at": null, "last_error": null,
                "created_at": "2026-01-01T00:00:00Z"
            }]
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-org/webhook-events") == true)
                return mockResponse(json: evtJSON)
            }

            let events = try await WebhookEventResource(http: http).list()
            #expect(events.count == 1)
            #expect(events[0].eventType == .passUpdated)
        }

        @Test func listWebhookEventsWithParams() async throws {
            MockURLProtocol.requestHandler = { request in
                let url = request.url!.absoluteString
                #expect(url.contains("event_type=pass.created"))
                #expect(url.contains("delivery_status=failed"))
                return mockResponse(json: "[]")
            }

            let params = ListWebhookEventsParams(eventType: .passCreated, deliveryStatus: .failed)
            let events = try await WebhookEventResource(http: http).list(params)
            #expect(events.isEmpty)
        }
    }
}
