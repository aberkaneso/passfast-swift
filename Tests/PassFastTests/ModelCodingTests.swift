import Testing
import Foundation
@testable import PassFast

@Suite("Model Coding")
struct ModelCodingTests {

    // MARK: - Enums

    @Test func passStatusRoundTrip() throws {
        for status in [PassStatus.active, .invalidated, .expired] {
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(PassStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test func walletTypeRoundTrip() throws {
        for wt in [WalletType.apple, .google] {
            let data = try JSONEncoder().encode(wt)
            let decoded = try JSONDecoder().decode(WalletType.self, from: data)
            #expect(decoded == wt)
        }
    }

    @Test func eventTypeRawValues() {
        #expect(EventType.passCreated.rawValue == "pass.created")
        #expect(EventType.deviceUnregistered.rawValue == "device.unregistered")
    }

    @Test func deliveryStatusRoundTrip() throws {
        for s in [DeliveryStatus.pending, .delivered, .failed] {
            let data = try JSONEncoder().encode(s)
            let decoded = try JSONDecoder().decode(DeliveryStatus.self, from: data)
            #expect(decoded == s)
        }
    }

    // MARK: - Models

    @Test func webhookEventDecoding() throws {
        let json = """
        {
            "id": "evt-1",
            "event_type": "pass.created",
            "payload": {"pass_id": "pass-1"},
            "delivery_status": "delivered",
            "attempts": 1,
            "delivered_at": "2026-01-01T00:00:00Z",
            "next_retry_at": null,
            "last_error": null,
            "created_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let evt = try JSONDecoder().decode(WebhookEvent.self, from: json)
        #expect(evt.eventType == .passCreated)
        #expect(evt.deliveryStatus == .delivered)
        #expect(evt.attempts == 1)
    }

    // MARK: - PassLocation

    @Test func passLocationRoundTrip() throws {
        let location = PassLocation(latitude: 37.7749, longitude: -122.4194, altitude: 10.0, relevantText: "Near HQ")
        let data = try JSONEncoder().encode(location)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["latitude"] as? Double == 37.7749)
        #expect(json["longitude"] as? Double == -122.4194)
        #expect(json["altitude"] as? Double == 10.0)
        #expect(json["relevantText"] as? String == "Near HQ")

        let decoded = try JSONDecoder().decode(PassLocation.self, from: data)
        #expect(decoded.latitude == 37.7749)
        #expect(decoded.longitude == -122.4194)
        #expect(decoded.altitude == 10.0)
        #expect(decoded.relevantText == "Near HQ")
    }

    @Test func passLocationMinimalFields() throws {
        let json = #"{"latitude": 40.0, "longitude": -74.0}"#.data(using: .utf8)!
        let location = try JSONDecoder().decode(PassLocation.self, from: json)
        #expect(location.latitude == 40.0)
        #expect(location.longitude == -74.0)
        #expect(location.altitude == nil)
        #expect(location.relevantText == nil)
    }

    // MARK: - Request Encoding

    @Test func generatePassRequestEncoding() throws {
        let req = GeneratePassRequest(
            templateId: "tmpl-1",
            serialNumber: "SN-001",
            data: ["name": "Jane"],
            externalId: "ext-1",
            getOrCreate: true
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["template_id"] as? String == "tmpl-1")
        #expect(json["serial_number"] as? String == "SN-001")
        #expect(json["external_id"] as? String == "ext-1")
        #expect(json["get_or_create"] as? Bool == true)
    }

    @Test func generatePassRequestWithLocationFields() throws {
        let req = GeneratePassRequest(
            templateId: "tmpl-1",
            serialNumber: "SN-001",
            data: ["name": "Jane"],
            locations: [PassLocation(latitude: 37.33, longitude: -122.03)],
            relevantDate: "2026-06-15T09:00:00Z",
            maxDistance: 500.0
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["relevant_date"] as? String == "2026-06-15T09:00:00Z")
        #expect(json["max_distance"] as? Double == 500.0)
        let locations = json["locations"] as? [[String: Any]]
        #expect(locations?.count == 1)
        #expect(locations?[0]["latitude"] as? Double == 37.33)
    }

    @Test func generatePassRequestWithWalletType() throws {
        let req = GeneratePassRequest(
            templateId: "tmpl-1",
            serialNumber: "SN-001",
            data: ["name": "Jane"],
            walletType: "google"
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["wallet_type"] as? String == "google")
    }

    @Test func updatePassRequestEncoding() throws {
        let req = UpdatePassRequest(data: ["name": "John"], pushUpdate: true)
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["push_update"] as? Bool == true)
        #expect(json["data"] != nil)
    }

    @Test func updatePassRequestWithLocationFields() throws {
        let req = UpdatePassRequest(
            locations: [PassLocation(latitude: 51.5, longitude: -0.12, relevantText: "London")],
            relevantDate: "2026-12-25T00:00:00Z",
            maxDistance: 1000.0
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["data"] == nil)
        #expect(json["relevant_date"] as? String == "2026-12-25T00:00:00Z")
        #expect(json["max_distance"] as? Double == 1000.0)
        let locations = json["locations"] as? [[String: Any]]
        #expect(locations?.count == 1)
        #expect(locations?[0]["relevantText"] as? String == "London")
    }

    @Test func updatePassRequestOptionalData() throws {
        let req = UpdatePassRequest(data: nil, pushUpdate: true)
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["push_update"] as? Bool == true)
        #expect(json["data"] == nil)
    }

    // MARK: - Response Decoding

    @Test func updatePassResponseDecoding() throws {
        let json = """
        {
            "id": "pass-1",
            "status": "active",
            "devices_notified": 3,
            "updated_at": "2026-01-02T00:00:00Z",
            "expires_at": null
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(UpdatePassResponse.self, from: json)
        #expect(resp.id == "pass-1")
        #expect(resp.status == .active)
        #expect(resp.devicesNotified == 3)
        #expect(resp.expiresAt == nil)
        #expect(resp.walletType == nil)
    }

    @Test func updatePassResponseWithWalletType() throws {
        let json = """
        {
            "id": "pass-1",
            "status": "active",
            "devices_notified": 1,
            "updated_at": "2026-01-02T00:00:00Z",
            "expires_at": null,
            "wallet_type": "google"
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(UpdatePassResponse.self, from: json)
        #expect(resp.walletType == "google")
    }

    @Test func voidPassResponseDecoding() throws {
        let json = """
        {
            "id": "pass-1",
            "serial_number": "SN-001",
            "status": "invalidated",
            "voided_at": "2026-01-02T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z",
            "pkpass_rebuilt": true,
            "devices_notified": 2,
            "warning": null
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(VoidPassResponse.self, from: json)
        #expect(resp.id == "pass-1")
        #expect(resp.status == .invalidated)
        #expect(resp.voidedAt == "2026-01-02T00:00:00Z")
        #expect(resp.pkpassRebuilt == true)
        #expect(resp.devicesNotified == 2)
        #expect(resp.warning == nil)
    }

    @Test func googleGenerateResponseDecoding() throws {
        let json = """
        {
            "id": "pass-1",
            "serial_number": "SN-001",
            "wallet_type": "google",
            "save_url": "https://pay.google.com/gp/v/save/...",
            "google_object_id": "issuer.SN-001",
            "status": "active",
            "external_id": null
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(GoogleGenerateResponse.self, from: json)
        #expect(resp.id == "pass-1")
        #expect(resp.walletType == "google")
        #expect(resp.saveUrl == "https://pay.google.com/gp/v/save/...")
        #expect(resp.googleObjectId == "issuer.SN-001")
    }

    @Test func dualGenerateResponseDecoding() throws {
        let json = """
        {
            "apple": {
                "id": "pass-a",
                "serial_number": "SN-001",
                "wallet_type": "apple",
                "status": "active",
                "download_url": "/manage-passes/pass-a/download"
            },
            "google": {
                "id": "pass-g",
                "serial_number": "SN-001",
                "wallet_type": "google",
                "status": "active",
                "save_url": "https://pay.google.com/gp/v/save/...",
                "google_object_id": "issuer.SN-001"
            },
            "warnings": []
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(DualGenerateResponse.self, from: json)
        #expect(resp.apple?.id == "pass-a")
        #expect(resp.apple?.downloadUrl == "/manage-passes/pass-a/download")
        #expect(resp.google?.id == "pass-g")
        #expect(resp.google?.saveUrl == "https://pay.google.com/gp/v/save/...")
        #expect(resp.warnings?.isEmpty == true)
    }

    @Test func dualGenerateResponsePartialFailure() throws {
        let json = """
        {
            "apple": {
                "id": "pass-a",
                "serial_number": "SN-001",
                "wallet_type": "apple",
                "status": "active",
                "download_url": "/manage-passes/pass-a/download"
            },
            "google": null,
            "warnings": ["Google generation failed: no credentials configured"]
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(DualGenerateResponse.self, from: json)
        #expect(resp.apple != nil)
        #expect(resp.google == nil)
        #expect(resp.warnings?.count == 1)
    }

    @Test func passDecodingWithWalletType() throws {
        let json = """
        {
            "id": "pass-1",
            "serial_number": "SN-001",
            "template_id": "tmpl-1",
            "organization_id": "org-1",
            "app_id": "app-1",
            "status": "active",
            "dynamic_data": {},
            "external_id": null,
            "authentication_token": "tok-1",
            "pkpass_storage_path": "/path",
            "pkpass_hash": "hash",
            "expires_at": null,
            "voided_at": null,
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
            "last_updated_at": null,
            "wallet_type": "google",
            "google_save_url": "https://pay.google.com/gp/v/save/...",
            "google_object_id": "issuer.SN-001"
        }
        """.data(using: .utf8)!
        let pass = try JSONDecoder().decode(Pass.self, from: json)
        #expect(pass.walletType == .google)
        #expect(pass.googleSaveUrl == "https://pay.google.com/gp/v/save/...")
        #expect(pass.googleObjectId == "issuer.SN-001")
    }

    // MARK: - Query Params

    @Test func listPassesParamsWithDateFilters() throws {
        let params = ListPassesParams(
            status: .active,
            createdAfter: "2026-01-01T00:00:00Z",
            createdBefore: "2026-02-01T00:00:00Z"
        )
        let items = params.queryItems
        #expect(items.contains { $0.name == "status" && $0.value == "active" })
        #expect(items.contains { $0.name == "created_after" && $0.value == "2026-01-01T00:00:00Z" })
        #expect(items.contains { $0.name == "created_before" && $0.value == "2026-02-01T00:00:00Z" })
    }

    @Test func listPassesParamsDateFiltersOmittedWhenNil() throws {
        let params = ListPassesParams(limit: 10)
        let items = params.queryItems
        #expect(!items.contains { $0.name == "created_after" })
        #expect(!items.contains { $0.name == "created_before" })
        #expect(items.contains { $0.name == "limit" && $0.value == "10" })
    }

    @Test func listPassesParamsWithWalletType() throws {
        let params = ListPassesParams(walletType: "google")
        let items = params.queryItems
        #expect(items.contains { $0.name == "wallet_type" && $0.value == "google" })
    }
}
