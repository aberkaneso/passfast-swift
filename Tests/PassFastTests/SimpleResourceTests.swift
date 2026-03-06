import Testing
import Foundation
@testable import PassFast

extension AllMockTests {
    @Suite("SimpleResource — Images, Certificates, API Keys, Members, Webhook Events")
    struct SimpleResourceTests {
        let http = makeTestHTTPClient()

        // MARK: - Images

        @Test func listImages() async throws {
            let imageJSON = """
            [{
                "id": "img-1", "organization_id": "org-1", "app_id": "app-1",
                "purpose": "icon", "mime_type": "image/png", "size_bytes": 4096,
                "width": 58, "height": 58,
                "storage_path": "/images/icon.png", "preview_url": null,
                "uploaded_at": "2026-01-01T00:00:00Z"
            }]
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-images") == true)
                return mockResponse(json: imageJSON)
            }

            let images = try await ImageResource(http: http).list()
            #expect(images.count == 1)
            #expect(images[0].purpose == .icon)
            #expect(images[0].mimeType == "image/png")
        }

        @Test func uploadImage() async throws {
            let responseJSON = """
            {
                "id": "img-2", "organization_id": "org-1", "app_id": "app-1",
                "purpose": "logo", "mime_type": "image/png", "size_bytes": 2048,
                "width": 100, "height": 50,
                "storage_path": "/images/logo.png", "preview_url": "https://example.com/preview/logo.png",
                "uploaded_at": "2026-01-01T00:00:00Z"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-images") == true)
                let contentType = request.value(forHTTPHeaderField: "Content-Type") ?? ""
                #expect(contentType.contains("multipart/form-data"))
                return mockResponse(json: responseJSON)
            }

            let result = try await ImageResource(http: http).upload(
                UploadImageRequest(purpose: .logo, fileData: Data("imagedata".utf8), fileName: "logo.png")
            )
            #expect(result.id == "img-2")
            #expect(result.purpose == .logo)
        }

        @Test func deleteImage() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-images/img-1") == true)
                return mockResponse(json: #"{"success":true}"#)
            }

            let result = try await ImageResource(http: http).delete("img-1")
            #expect(result.success == true)
        }

        // MARK: - Certificates

        @Test func listCertificates() async throws {
            let certJSON = """
            [{
                "id": "cert-1", "app_id": "app-1",
                "cert_type": "wwdr", "cert_hash": "hash1",
                "common_name": null,
                "is_active": true, "valid_from": null, "valid_until": null,
                "created_at": "2026-01-01T00:00:00Z"
            }]
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-certs") == true)
                return mockResponse(json: certJSON)
            }

            let certs = try await CertificateResource(http: http).list()
            #expect(certs.count == 1)
            #expect(certs[0].certType == .wwdr)
        }

        @Test func uploadCertificate() async throws {
            let responseJSON = """
            {
                "id": "cert-2", "app_id": "app-1",
                "cert_type": "signer_cert", "cert_hash": "hash2",
                "common_name": "Apple Signer",
                "is_active": true, "valid_from": null, "valid_until": null,
                "created_at": "2026-01-01T00:00:00Z"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-certs") == true)
                return mockResponse(json: responseJSON)
            }

            let cert = try await CertificateResource(http: http).upload(
                UploadCertificateRequest(certType: .signerCert, certData: "PEM_DATA")
            )
            #expect(cert.id == "cert-2")
            #expect(cert.certType == .signerCert)
        }

        @Test func uploadP12Certificate() async throws {
            let responseJSON = """
            {
                "message": "P12 bundle uploaded successfully",
                "certificates": [{
                    "id": "cert-3", "app_id": "app-1",
                    "cert_type": "signer_cert", "cert_hash": "hash3",
                    "common_name": null,
                    "is_active": true, "valid_from": null, "valid_until": null,
                    "created_at": "2026-01-01T00:00:00Z"
                }]
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-certs/p12") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await CertificateResource(http: http).uploadP12(
                UploadP12Request(p12Data: "cDEyZGF0YQ==", password: "secret")
            )
            #expect(result.certificates.count == 1)
            #expect(result.message.contains("successfully"))
        }

        @Test func deleteCertificate() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-certs/cert-1") == true)
                return mockResponse(json: #"{"success":true}"#)
            }

            let result = try await CertificateResource(http: http).delete("cert-1")
            #expect(result.success == true)
        }

        // MARK: - API Keys

        @Test func listApiKeys() async throws {
            let keyJSON = """
            [{
                "id": "key-1", "name": "Prod Key",
                "key_type": "secret", "key_prefix": "sk_live_",
                "scopes": ["passes:write"], "expires_at": null,
                "is_active": true, "last_used_at": null,
                "created_at": "2026-01-01T00:00:00Z"
            }]
            """
            MockURLProtocol.requestHandler = { _ in mockResponse(json: keyJSON) }

            let keys = try await APIKeyResource(http: http).list()
            #expect(keys.count == 1)
            #expect(keys[0].keyType == .secret)
            #expect(keys[0].keyPrefix == "sk_live_")
        }

        @Test func createApiKey() async throws {
            let responseJSON = """
            {
                "id": "key-2", "name": "New Key",
                "key_type": "publishable", "key_prefix": "pk_live_",
                "scopes": ["passes:read"], "raw_key": "pk_live_newkey123",
                "message": "API key created",
                "expires_at": null, "is_active": true,
                "created_at": "2026-01-01T00:00:00Z"
            }
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                return mockResponse(json: responseJSON)
            }

            let key = try await APIKeyResource(http: http).create(CreateApiKeyRequest(name: "New Key", keyType: .publishable))
            #expect(key.rawKey == "pk_live_newkey123")
        }

        @Test func revokeApiKey() async throws {
            let responseJSON = #"{"id":"key-1","is_active":false,"message":"API key revoked"}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                #expect(request.url?.path.hasSuffix("/manage-keys/key-1") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await APIKeyResource(http: http).revoke("key-1")
            #expect(result.isActive == false)
            #expect(result.id == "key-1")
        }

        @Test func deleteApiKey() async throws {
            let responseJSON = #"{"id":"key-1","message":"API key deleted"}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-keys/key-1") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await APIKeyResource(http: http).delete("key-1")
            #expect(result.id == "key-1")
        }

        // MARK: - Members

        @Test func listMembers() async throws {
            let responseJSON = """
            [{"id":"m-1","user_id":"u-1","email":"a@b.com","role":"owner","created_at":"2026-01-01T00:00:00Z"}]
            """
            MockURLProtocol.requestHandler = { _ in mockResponse(json: responseJSON) }

            let members = try await MemberResource(http: http).list()
            #expect(members.count == 1)
            #expect(members[0].role == .owner)
            #expect(members[0].id == "m-1")
        }

        @Test func listInvitations() async throws {
            let responseJSON = """
            [{"id":"inv-1","email":"c@d.com","role":"viewer","status":"pending","expires_at":"2026-02-01T00:00:00Z","created_at":"2026-01-01T00:00:00Z"}]
            """
            MockURLProtocol.requestHandler = { request in
                #expect(request.url?.path.hasSuffix("/manage-members/invitations") == true)
                return mockResponse(json: responseJSON)
            }

            let invitations = try await MemberResource(http: http).listInvitations()
            #expect(invitations.count == 1)
            #expect(invitations[0].status == .pending)
        }

        @Test func inviteMember() async throws {
            let responseJSON = #"{"id":"inv-2","email":"new@example.com","role":"editor","status":"pending","expires_at":"2026-02-01T00:00:00Z","created_at":"2026-01-01T00:00:00Z"}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-members/invite") == true)
                return mockResponse(json: responseJSON)
            }

            let inv = try await MemberResource(http: http).invite(InviteMemberRequest(email: "new@example.com", role: .editor))
            #expect(inv.email == "new@example.com")
            #expect(inv.role == .editor)
        }

        @Test func acceptInvitation() async throws {
            let responseJSON = #"{"organization_id":"org-1","user_id":"u-2","role":"editor"}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.path.hasSuffix("/manage-members/accept") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await MemberResource(http: http).acceptInvitation(AcceptInvitationRequest(token: "tok-123"))
            #expect(result.organizationId == "org-1")
            #expect(result.role == .editor)
        }

        @Test func revokeInvitation() async throws {
            let responseJSON = #"{"id":"inv-1","status":"revoked"}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-members/invitations/inv-1") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await MemberResource(http: http).revokeInvitation("inv-1")
            #expect(result.status == .revoked)
        }

        @Test func changeRole() async throws {
            let responseJSON = #"{"id":"m-1","role":"admin"}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "PATCH")
                #expect(request.url?.path.hasSuffix("/manage-members/u-1") == true)
                #expect(request.url?.path.hasSuffix("/manage-members/u-1/role") == false)
                return mockResponse(json: responseJSON)
            }

            let result = try await MemberResource(http: http).changeRole("u-1", ChangeRoleRequest(role: .admin))
            #expect(result.id == "m-1")
            #expect(result.role == .admin)
        }

        @Test func removeMember() async throws {
            let responseJSON = #"{"id":"u-1","removed":true}"#
            MockURLProtocol.requestHandler = { request in
                #expect(request.httpMethod == "DELETE")
                #expect(request.url?.path.hasSuffix("/manage-members/u-1") == true)
                return mockResponse(json: responseJSON)
            }

            let result = try await MemberResource(http: http).remove("u-1")
            #expect(result.id == "u-1")
            #expect(result.removed == true)
        }

        // MARK: - Webhook Events

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
