import Testing
import Foundation
@testable import PassFast

@Test func clientInitialization() {
    let client = PassFastClient(apiKey: "sk_live_test")
    // Verify all resources are accessible (non-optional properties, so just access them)
    _ = client.passes
    _ = client.templates
    _ = client.images
    _ = client.certificates
    _ = client.organization
    _ = client.apiKeys
    _ = client.members
    _ = client.webhookEvents
}

@Test func anyCodableString() throws {
    let value: AnyCodable = "hello"
    let data = try JSONEncoder().encode(value)
    let decoded = try JSONDecoder().decode(AnyCodable.self, from: data)
    #expect(decoded == AnyCodable("hello"))
}

@Test func anyCodableDictionary() throws {
    let json = """
    {"name": "Jane", "age": 30, "active": true}
    """.data(using: .utf8)!
    let decoded = try JSONDecoder().decode([String: AnyCodable].self, from: json)
    #expect(decoded["name"] == AnyCodable("Jane"))
    #expect(decoded["age"] == AnyCodable(30))
    #expect(decoded["active"] == AnyCodable(true))
}

@Test func generatePassRequestEncoding() throws {
    let request = GeneratePassRequest(
        templateId: "tmpl-123",
        serialNumber: "SN-001",
        data: ["name": "Jane Doe", "points": "1250"]
    )
    let data = try JSONEncoder().encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    #expect(json["template_id"] as? String == "tmpl-123")
    #expect(json["serial_number"] as? String == "SN-001")
    #expect(json["data"] != nil)
}

@Test func passDecoding() throws {
    let json = """
    {
        "id": "pass-123",
        "serial_number": "SN-001",
        "template_id": "tmpl-123",
        "organization_id": "org-123",
        "app_id": "app-123",
        "status": "active",
        "dynamic_data": {"name": "Jane"},
        "external_id": null,
        "authentication_token": "tok-123",
        "pkpass_storage_path": "/path/to/pass.pkpass",
        "pkpass_hash": "abc123",
        "expires_at": null,
        "voided_at": null,
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-01-01T00:00:00Z",
        "last_updated_at": null
    }
    """.data(using: .utf8)!

    let pass = try JSONDecoder().decode(Pass.self, from: json)
    #expect(pass.id == "pass-123")
    #expect(pass.serialNumber == "SN-001")
    #expect(pass.status == .active)
    #expect(pass.dynamicData["name"] == AnyCodable("Jane"))
}

@Test func errorParsing() {
    let json = """
    {"error": {"code": "not_found", "message": "Pass not found"}}
    """.data(using: .utf8)!

    let error = parseAPIError(statusCode: 404, data: json)
    if case .notFound(let msg) = error {
        #expect(msg == "Pass not found")
    } else {
        Issue.record("Expected notFound error")
    }
}
