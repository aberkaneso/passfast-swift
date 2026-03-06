import Testing
import Foundation
@testable import PassFast

private let templateJSON = """
{
    "id": "tmpl-1", "organization_id": "org-1", "app_id": "app-1",
    "name": "Loyalty Card", "description": null, "pass_style": "storeCard",
    "structure": {"key": "value"}, "field_schema": null,
    "is_published": false, "is_archived": false,
    "icon_image_id": null, "logo_image_id": null, "strip_image_id": null,
    "thumbnail_image_id": null, "background_image_id": null,
    "published_at": null,
    "created_at": "2026-01-01T00:00:00Z", "updated_at": "2026-01-01T00:00:00Z"
}
"""

extension AllMockTests {
    @Suite("TemplateResource")
    struct TemplateResourceTests {
        let http = makeTestHTTPClient()
        var resource: TemplateResource { TemplateResource(http: http) }

        @Test func createTemplate() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-templates") == true)
                return mockResponse(json: templateJSON)
            }

            let req = CreateTemplateRequest(name: "Loyalty Card", passStyle: .storeCard, structure: ["key": "value"])
            let template = try await resource.create(req)
            #expect(template.id == "tmpl-1")
            #expect(template.passStyle == .storeCard)
        }

        @Test func listTemplates() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                return mockResponse(json: "[\(templateJSON)]")
            }

            let templates = try await resource.list()
            #expect(templates.count == 1)
        }

        @Test func getTemplate() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-templates/tmpl-1") == true)
                return mockResponse(json: templateJSON)
            }

            let template = try await resource.get("tmpl-1")
            #expect(template.name == "Loyalty Card")
        }

        @Test func updateTemplate() async throws {
            let updatedJSON = templateJSON.replacingOccurrences(of: "Loyalty Card", with: "VIP Card")
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                return mockResponse(json: updatedJSON)
            }

            let template = try await resource.update("tmpl-1", UpdateTemplateRequest(name: "VIP Card"))
            #expect(template.name == "VIP Card")
        }

        @Test func deleteTemplate() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-templates/tmpl-1") == true)
                return mockResponse(json: #"{"success":true}"#)
            }

            let result = try await resource.delete("tmpl-1")
            #expect(result.success == true)
        }

        @Test func publishTemplate() async throws {
            let publishedJSON = templateJSON
                .replacingOccurrences(of: "\"is_published\": false", with: "\"is_published\": true")
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-templates/tmpl-1/publish") == true)
                return mockResponse(json: publishedJSON)
            }

            let template = try await resource.publish("tmpl-1")
            #expect(template.isPublished == true)
        }
    }
}
