import Testing
import Foundation
@testable import PassFast

@Suite("Model Coding")
struct ModelCodingTests {

    // MARK: - Enums

    @Test func passStyleRoundTrip() throws {
        for style in [PassStyle.coupon, .eventTicket, .generic, .boardingPass, .storeCard] {
            let data = try JSONEncoder().encode(style)
            let decoded = try JSONDecoder().decode(PassStyle.self, from: data)
            #expect(decoded == style)
        }
    }

    @Test func passStatusRoundTrip() throws {
        for status in [PassStatus.active, .invalidated, .expired] {
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(PassStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test func templateStatusRoundTrip() throws {
        for status in [TemplateStatus.draft, .published, .archived] {
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(TemplateStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test func invitationStatusRoundTrip() throws {
        for status in [InvitationStatus.pending, .accepted, .expired, .revoked] {
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(InvitationStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test func certTypeRawValues() {
        #expect(CertType.signerCert.rawValue == "signer_cert")
        #expect(CertType.signerKey.rawValue == "signer_key")
        #expect(CertType.wwdr.rawValue == "wwdr")
    }

    @Test func keyTypeRoundTrip() throws {
        for kt in [KeyType.secret, .publishable] {
            let data = try JSONEncoder().encode(kt)
            let decoded = try JSONDecoder().decode(KeyType.self, from: data)
            #expect(decoded == kt)
        }
    }

    @Test func orgRoleRoundTrip() throws {
        for role in [OrgRole.owner, .admin, .editor, .viewer] {
            let data = try JSONEncoder().encode(role)
            let decoded = try JSONDecoder().decode(OrgRole.self, from: data)
            #expect(decoded == role)
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

    @Test func templateDecoding() throws {
        let json = """
        {
            "id": "tmpl-1",
            "organization_id": "org-1",
            "app_id": "app-1",
            "name": "Loyalty Card",
            "description": null,
            "pass_style": "storeCard",
            "structure": {"key": "value"},
            "field_schema": null,
            "status": "draft",
            "icon_image_id": null,
            "logo_image_id": null,
            "strip_image_id": null,
            "thumbnail_image_id": null,
            "background_image_id": null,
            "published_at": null,
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let template = try JSONDecoder().decode(Template.self, from: json)
        #expect(template.id == "tmpl-1")
        #expect(template.passStyle == .storeCard)
        #expect(template.status == .draft)
        #expect(template.fieldSchema == nil)
    }

    @Test func organizationDecoding() throws {
        let json = """
        {"id":"org-1","name":"Acme","slug":"acme","apns_key_id":null,"billing_plan":"pro",
         "monthly_pass_limit":10000,"features":null,"is_active":true,"webhook_secret":null,
         "created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z"}
        """.data(using: .utf8)!
        let org = try JSONDecoder().decode(Organization.self, from: json)
        #expect(org.id == "org-1")
        #expect(org.name == "Acme")
        #expect(org.slug == "acme")
        #expect(org.billingPlan == "pro")
        #expect(org.isActive == true)
    }

    @Test func appDecoding() throws {
        let json = """
        {
            "id": "app-1",
            "organization_id": "org-1",
            "name": "My App",
            "apple_team_id": "TEAM123",
            "pass_type_identifier": "pass.com.example",
            "validation_webhook_url": null,
            "webhook_url": null,
            "is_active": true,
            "webhook_secret": null,
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let app = try JSONDecoder().decode(App.self, from: json)
        #expect(app.id == "app-1")
        #expect(app.appleTeamId == "TEAM123")
        #expect(app.passTypeIdentifier == "pass.com.example")
        #expect(app.isActive == true)
    }

    @Test func apiKeyDecoding() throws {
        let json = """
        {
            "id": "key-1",
            "organization_id": "org-1",
            "name": "Production",
            "key_type": "secret",
            "key_prefix": "sk_live_",
            "scopes": ["passes:write", "passes:read"],
            "expires_at": null,
            "is_active": true,
            "last_used_at": null,
            "created_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let key = try JSONDecoder().decode(ApiKey.self, from: json)
        #expect(key.keyType == .secret)
        #expect(key.scopes.count == 2)
        #expect(key.keyPrefix == "sk_live_")
        #expect(key.isActive == true)
    }

    @Test func apiKeyCreatedDecoding() throws {
        let json = """
        {
            "id": "key-1",
            "organization_id": "org-1",
            "name": "New Key",
            "key_type": "publishable",
            "key_prefix": "pk_live_",
            "scopes": ["passes:read"],
            "raw_key": "pk_live_abc123xyz",
            "expires_at": null,
            "is_active": true,
            "created_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let key = try JSONDecoder().decode(ApiKeyCreated.self, from: json)
        #expect(key.rawKey == "pk_live_abc123xyz")
        #expect(key.keyType == .publishable)
        #expect(key.keyPrefix == "pk_live_")
    }

    @Test func memberDecoding() throws {
        let json = #"{"id":"m-1","user_id":"user-1","email":"a@b.com","role":"admin","created_at":"2026-01-01T00:00:00Z"}"#.data(using: .utf8)!
        let member = try JSONDecoder().decode(Member.self, from: json)
        #expect(member.id == "m-1")
        #expect(member.userId == "user-1")
        #expect(member.role == .admin)
    }

    @Test func invitationDecoding() throws {
        let json = """
        {"id":"inv-1","email":"b@c.com","role":"editor","status":"pending","expires_at":"2026-02-01T00:00:00Z","created_at":"2026-01-01T00:00:00Z"}
        """.data(using: .utf8)!
        let inv = try JSONDecoder().decode(Invitation.self, from: json)
        #expect(inv.id == "inv-1")
        #expect(inv.role == .editor)
        #expect(inv.status == .pending)
    }

    @Test func passImageDecoding() throws {
        let json = """
        {
            "id": "img-1",
            "organization_id": "org-1",
            "app_id": "app-1",
            "purpose": "icon",
            "filename": "icon.png",
            "storage_path": "/images/icon.png",
            "preview_url": "https://example.com/preview/icon.png",
            "created_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let img = try JSONDecoder().decode(PassImage.self, from: json)
        #expect(img.purpose == "icon")
        #expect(img.previewUrl == "https://example.com/preview/icon.png")
    }

    @Test func certificateDecoding() throws {
        let json = """
        {
            "id": "cert-1",
            "organization_id": "org-1",
            "app_id": "app-1",
            "cert_type": "signer_cert",
            "filename": "cert.pem",
            "subject": "CN=PassFast",
            "issuer": "Apple",
            "valid_from": "2025-01-01",
            "valid_to": "2026-01-01",
            "is_active": true,
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z"
        }
        """.data(using: .utf8)!
        let cert = try JSONDecoder().decode(Certificate.self, from: json)
        #expect(cert.certType == .signerCert)
        #expect(cert.isActive == true)
        #expect(cert.subject == "CN=PassFast")
        #expect(cert.updatedAt == "2026-01-02T00:00:00Z")
    }

    @Test func webhookEventDecoding() throws {
        let json = """
        {
            "id": "evt-1",
            "organization_id": "org-1",
            "app_id": "app-1",
            "event_type": "pass.created",
            "payload": {"pass_id": "pass-1"},
            "delivery_status": "delivered",
            "attempts": 1,
            "last_attempt_at": "2026-01-01T00:00:00Z",
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

    @Test func createTemplateRequestEncoding() throws {
        let req = CreateTemplateRequest(
            name: "Loyalty",
            passStyle: .storeCard,
            structure: ["key": "val"]
        )
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["name"] as? String == "Loyalty")
        #expect(json["pass_style"] as? String == "storeCard")
    }

    @Test func createApiKeyRequestEncoding() throws {
        let req = CreateApiKeyRequest(name: "Test", keyType: .secret, scopes: ["passes:read"])
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["key_type"] as? String == "secret")
        #expect((json["scopes"] as? [String])?.first == "passes:read")
    }

    @Test func updatePassRequestEncoding() throws {
        let req = UpdatePassRequest(data: ["name": "John"], pushUpdate: true)
        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["push_update"] as? Bool == true)
        #expect(json["data"] != nil)
    }

    @Test func updatePassResponseDecoding() throws {
        let json = """
        {
            "id": "pass-1",
            "status": "active",
            "devices_notified": 3,
            "updated_at": "2026-01-02T00:00:00Z"
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(UpdatePassResponse.self, from: json)
        #expect(resp.id == "pass-1")
        #expect(resp.status == .active)
        #expect(resp.devicesNotified == 3)
    }

    @Test func voidPassResponseDecoding() throws {
        let json = """
        {
            "id": "pass-1",
            "serial_number": "SN-001",
            "status": "invalidated",
            "voided_at": "2026-01-02T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z"
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(VoidPassResponse.self, from: json)
        #expect(resp.id == "pass-1")
        #expect(resp.status == .invalidated)
        #expect(resp.voidedAt == "2026-01-02T00:00:00Z")
    }
}
