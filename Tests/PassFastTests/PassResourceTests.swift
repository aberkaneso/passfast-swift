import Testing
import Foundation
@testable import PassFast

private let passJSON = """
{
    "id": "pass-1", "serial_number": "SN-001", "template_id": "tmpl-1",
    "organization_id": "org-1", "app_id": "app-1", "status": "active",
    "dynamic_data": {"name": "Jane"}, "external_id": null,
    "authentication_token": "tok-1", "pkpass_storage_path": "/p.pkpass",
    "pkpass_hash": "abc", "expires_at": null, "voided_at": null,
    "created_at": "2026-01-01T00:00:00Z", "updated_at": "2026-01-01T00:00:00Z",
    "last_updated_at": null
}
"""

extension AllMockTests {
    @Suite("PassResource")
    struct PassResourceTests {
        let http = makeTestHTTPClient()
        var resource: PassResource { PassResource(http: http) }

        @Test func generatePass() async throws {
            let pkpassData = Data("fake-pkpass".utf8)
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/generate-pass") == true)
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: [
                        "X-Pass-Id": "pass-1",
                        "X-Pass-Existed": "false"
                    ]
                )!
                return (response, pkpassData)
            }

            let req = GeneratePassRequest(templateId: "tmpl-1", serialNumber: "SN-001", data: ["name": "Jane"])
            let result = try await resource.generate(req)
            #expect(result.passId == "pass-1")
            #expect(result.existed == false)
            #expect(result.pkpassData == pkpassData)
        }

        @Test func generatePassExisted() async throws {
            MockURLProtocol.requestHandler = { request in
                let response = HTTPURLResponse(
                    url: request.url!, statusCode: 200, httpVersion: nil,
                    headerFields: ["X-Pass-Id": "pass-2", "X-Pass-Existed": "true"]
                )!
                return (response, Data("pkpass".utf8))
            }

            let req = GeneratePassRequest(templateId: "tmpl-1", serialNumber: "SN-002", data: [:], getOrCreate: true)
            let result = try await resource.generate(req)
            #expect(result.passId == "pass-2")
            #expect(result.existed == true)
        }

        @Test func listPasses() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/manage-passes") == true)
                return mockResponse(json: "[\(passJSON)]")
            }

            let passes = try await resource.list()
            #expect(passes.count == 1)
            #expect(passes[0].id == "pass-1")
        }

        @Test func listPassesWithParams() async throws {
            MockURLProtocol.requestHandler = { request in
                let url = request.url!.absoluteString
                #expect(url.contains("status=active"))
                #expect(url.contains("limit=5"))
                return mockResponse(json: "[]")
            }

            let params = ListPassesParams(status: .active, limit: 5)
            let passes = try await resource.list(params)
            #expect(passes.isEmpty)
        }

        @Test func listPassesWithDateParams() async throws {
            MockURLProtocol.requestHandler = { request in
                let url = request.url!.absoluteString
                #expect(url.contains("created_after=2026-01-01"))
                #expect(url.contains("created_before=2026-02-01"))
                return mockResponse(json: "[]")
            }

            let params = ListPassesParams(createdAfter: "2026-01-01", createdBefore: "2026-02-01")
            let passes = try await resource.list(params)
            #expect(passes.isEmpty)
        }

        @Test func getPass() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/manage-passes/pass-1") == true)
                return mockResponse(json: passJSON)
            }

            let pass = try await resource.get("pass-1")
            #expect(pass.id == "pass-1")
            #expect(pass.serialNumber == "SN-001")
        }

        @Test func downloadPass() async throws {
            let binaryData = Data([0x50, 0x4B, 0x03, 0x04])
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-passes/pass-1/download") == true)
                return mockResponse(data: binaryData, headers: ["Content-Type": "application/vnd.apple.pkpass"])
            }

            let data = try await resource.download("pass-1")
            #expect(data == binaryData)
        }

        @Test func updatePass() async throws {
            let responseJSON = """
            {
                "id": "pass-1",
                "status": "active",
                "devices_notified": 2,
                "updated_at": "2026-01-02T00:00:00Z"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                #expect(request.url?.path.hasSuffix("/manage-passes/pass-1") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.update("pass-1", UpdatePassRequest(data: ["name": "John"]))
            #expect(result.id == "pass-1")
            #expect(result.devicesNotified == 2)
        }

        @Test func voidPass() async throws {
            let responseJSON = """
            {
                "id": "pass-1",
                "serial_number": "SN-001",
                "status": "invalidated",
                "voided_at": "2026-01-02T00:00:00Z",
                "updated_at": "2026-01-02T00:00:00Z"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-passes/pass-1/void") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.void("pass-1")
            #expect(result.status == .invalidated)
            #expect(result.voidedAt == "2026-01-02T00:00:00Z")
        }

        @Test func deletePass() async throws {
            let responseJSON = #"{"id":"pass-1","serial_number":"SN-001","deleted":true}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-passes/pass-1") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.delete("pass-1")
            #expect(result.id == "pass-1")
            #expect(result.deleted == true)
        }

        @Test func getPassBySerial() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "GET")
                #expect(request.url?.path.hasSuffix("/manage-passes/serial/SN-001") == true)
                return mockResponse(json: passJSON)
            }

            let pass = try await resource.getBySerial("SN-001")
            #expect(pass.id == "pass-1")
            #expect(pass.serialNumber == "SN-001")
        }

        @Test func updatePassBySerial() async throws {
            let responseJSON = """
            {"id":"pass-1","status":"active","devices_notified":1,"updated_at":"2026-01-02T00:00:00Z"}
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                #expect(request.url?.path.hasSuffix("/manage-passes/serial/SN-001") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.updateBySerial("SN-001", UpdatePassRequest(data: ["name": "John"]))
            #expect(result.id == "pass-1")
            #expect(result.devicesNotified == 1)
        }

        @Test func deletePassBySerial() async throws {
            let responseJSON = #"{"id":"pass-1","serial_number":"SN-001","deleted":true}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-passes/serial/SN-001") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await resource.deleteBySerial("SN-001")
            #expect(result.serialNumber == "SN-001")
            #expect(result.deleted == true)
        }

        @Test func downloadPassBySerial() async throws {
            let binaryData = Data([0x50, 0x4B, 0x03, 0x04])
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-passes/serial/SN-001/download") == true)
                return mockResponse(data: binaryData, headers: ["Content-Type": "application/vnd.apple.pkpass"])
            }

            let data = try await resource.downloadBySerial("SN-001")
            #expect(data == binaryData)
        }

        @Test func generatePassAPIError() async throws {
            MockURLProtocol.requestHandler = { _ in
                return mockResponse(statusCode: 401, json: #"{"error":{"code":"auth","message":"Invalid key"}}"#)
            }

            await #expect(throws: PassFastError.self) {
                let req = GeneratePassRequest(templateId: "t", serialNumber: "s", data: [:])
                _ = try await resource.generate(req)
            }
        }

        @Test func listPassesAPIError() async throws {
            MockURLProtocol.requestHandler = { _ in
                return mockResponse(statusCode: 403, json: #"{"error":{"code":"forbidden","message":"No access"}}"#)
            }

            await #expect(throws: PassFastError.self) {
                _ = try await resource.list()
            }
        }

        @Test func getPassNotFound() async throws {
            MockURLProtocol.requestHandler = { _ in
                return mockResponse(statusCode: 404, json: #"{"error":{"code":"not_found","message":"Not found"}}"#)
            }

            do {
                _ = try await resource.get("nonexistent")
                Issue.record("Expected error")
            } catch let error as PassFastError {
                guard case .notFound = error else {
                    Issue.record("Expected notFound, got \(error)"); return
                }
            }
        }
    }
}
