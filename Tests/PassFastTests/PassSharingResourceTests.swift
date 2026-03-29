import Testing
import Foundation
@testable import PassFast

extension AllMockTests {
    @Suite("PassSharingResource")
    struct PassSharingResourceTests {
        let http = makeTestHTTPClient()
        var resource: PassSharingResource { PassSharingResource(http: http) }

        @Test func createShareToken() async throws {
            let responseJSON = """
            {"share_token": "abc123def456", "share_url": "https://pass.example.com/s/abc123def456"}
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/share-pass/create") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.createShareToken(CreateShareTokenRequest(passId: "pass-1"))
            #expect(result.shareToken == "abc123def456")
            #expect(result.shareUrl == "https://pass.example.com/s/abc123def456")
        }

        @Test func getMetadata() async throws {
            let responseJSON = """
            {
                "serial_number": "SN-001",
                "status": "active",
                "has_apple": true,
                "has_google": true,
                "google_save_url": "https://pay.google.com/gp/v/save/...",
                "template_name": "Loyalty Card",
                "pass_style": "storeCard",
                "app_name": "My App",
                "org_name": "Acme"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/share-pass/abc123") == true)
                return mockResponse(json: responseJSON)
            }

            let meta = try await resource.getMetadata("abc123")
            #expect(meta.serialNumber == "SN-001")
            #expect(meta.hasApple == true)
            #expect(meta.hasGoogle == true)
            #expect(meta.googleSaveUrl == "https://pay.google.com/gp/v/save/...")
        }

        @Test func downloadSharedPass() async throws {
            let binaryData = Data([0x50, 0x4B, 0x03, 0x04])
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/share-pass/abc123/download") == true)
                return mockResponse(data: binaryData, headers: ["Content-Type": "application/vnd.apple.pkpass"])
            }

            let data = try await resource.download("abc123")
            #expect(data == binaryData)
        }
    }
}
