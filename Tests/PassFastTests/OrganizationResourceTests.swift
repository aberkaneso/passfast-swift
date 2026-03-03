import Testing
import Foundation
@testable import PassFast

private let orgJSON = """
{"id":"org-1","name":"Acme","slug":null,"apns_key_id":null,"billing_plan":null,
 "monthly_pass_limit":null,"features":null,"is_active":true,"webhook_secret":null,
 "created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z"}
"""

private let appJSON = """
{
    "id": "app-1", "organization_id": "org-1", "name": "My App",
    "apple_team_id": "TEAM1", "pass_type_identifier": "pass.com.example",
    "validation_webhook_url": null, "webhook_url": null,
    "is_active": true, "webhook_secret": null,
    "created_at": "2026-01-01T00:00:00Z", "updated_at": "2026-01-01T00:00:00Z"
}
"""

extension AllMockTests {
    @Suite("OrganizationResource")
    struct OrganizationResourceTests {
        let http = makeTestHTTPClient()
        var resource: OrganizationResource { OrganizationResource(http: http) }

        @Test func getOrg() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/manage-org") == true)
                return mockResponse(json: orgJSON)
            }

            let org = try await resource.get()
            #expect(org.id == "org-1")
            #expect(org.name == "Acme")
        }

        @Test func updateOrg() async throws {
            let updatedJSON = orgJSON.replacingOccurrences(of: "Acme", with: "Acme Corp")
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                return mockResponse(json: updatedJSON)
            }

            let org = try await resource.update(UpdateOrgRequest(name: "Acme Corp"))
            #expect(org.name == "Acme Corp")
        }

        @Test func getApp() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/manage-org/app") == true)
                return mockResponse(json: appJSON)
            }

            let app = try await resource.getApp()
            #expect(app.id == "app-1")
            #expect(app.name == "My App")
        }

        @Test func listApps() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-org/app") == true)
                return mockResponse(json: "[\(appJSON)]")
            }

            let apps = try await resource.listApps()
            #expect(apps.count == 1)
            #expect(apps[0].name == "My App")
        }

        @Test func createApp() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-org/app") == true)
                return mockResponse(json: appJSON)
            }

            let app = try await resource.createApp(CreateAppRequest(name: "My App"))
            #expect(app.id == "app-1")
        }

        @Test func updateApp() async throws {
            let responseJSON = """
            {
                "id": "app-1", "organization_id": "org-1", "name": "Updated App",
                "apple_team_id": "TEAM1", "pass_type_identifier": "pass.com.example",
                "validation_webhook_url": null, "webhook_url": "https://hook.example.com",
                "webhook_secret_raw": "whsec_123", "is_active": true, "webhook_secret": null,
                "created_at": "2026-01-01T00:00:00Z", "updated_at": "2026-01-02T00:00:00Z"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                #expect(request.url?.path.hasSuffix("/manage-org/app") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.updateApp(UpdateAppRequest(name: "Updated App", regenerateWebhookSecret: true))
            #expect(result.name == "Updated App")
            #expect(result.webhookSecretRaw == "whsec_123")
        }

        @Test func deleteApp() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-org/app") == true)
                return mockResponse(statusCode: 200, data: Data())
            }

            try await resource.deleteApp()
        }

        @Test func testWebhook() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-org/app/test-webhook") == true)
                return mockResponse(json: """
                {"webhook_url":"https://hook.example.com","success":true,"approved":true,"reason":null,"status_code":200,"duration_ms":150}
                """)
            }

            let result = try await resource.testWebhook()
            #expect(result.success == true)
            #expect(result.statusCode == 200)
            #expect(result.approved == true)
        }
    }
}
