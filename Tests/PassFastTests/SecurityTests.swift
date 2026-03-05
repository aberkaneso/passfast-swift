import Testing
import Foundation
@testable import PassFast

// MARK: - Path Sanitization Tests

@Suite("Path Sanitization")
struct PathSanitizationTests {
    @Test func rejectsPathTraversalWithSlash() {
        #expect(throws: PassFastError.self) {
            _ = try RequestBuilder.sanitizePathComponent("../admin/keys")
        }
    }

    @Test func rejectsPathTraversalWithDoubleDot() {
        #expect(throws: PassFastError.self) {
            _ = try RequestBuilder.sanitizePathComponent("..admin")
        }
    }

    @Test func rejectsSlashInId() {
        #expect(throws: PassFastError.self) {
            _ = try RequestBuilder.sanitizePathComponent("abc/def")
        }
    }

    @Test func rejectsEmptyId() {
        #expect(throws: PassFastError.self) {
            _ = try RequestBuilder.sanitizePathComponent("")
        }
    }

    @Test func allowsValidId() throws {
        let result = try RequestBuilder.sanitizePathComponent("pass-123_abc")
        #expect(result == "pass-123_abc")
    }

    @Test func allowsUUIDId() throws {
        let result = try RequestBuilder.sanitizePathComponent("550e8400-e29b-41d4-a716-446655440000")
        #expect(result == "550e8400-e29b-41d4-a716-446655440000")
    }

    @Test func encodesSpecialCharacters() throws {
        let result = try RequestBuilder.sanitizePathComponent("id with spaces")
        #expect(result.contains("%20") || result.contains("+"))
    }
}

// MARK: - AnyCodable Equality Tests

@Suite("AnyCodable Type-Safe Equality")
struct AnyCodableEqualityTests {
    @Test func intNotEqualToString() {
        #expect(AnyCodable(1) != AnyCodable("1"))
    }

    @Test func boolNotEqualToInt() {
        #expect(AnyCodable(true) != AnyCodable(1))
    }

    @Test func sameTypeIntEquality() {
        #expect(AnyCodable(42) == AnyCodable(42))
    }

    @Test func sameTypeStringEquality() {
        #expect(AnyCodable("hello") == AnyCodable("hello"))
    }

    @Test func sameTypeBoolEquality() {
        #expect(AnyCodable(true) == AnyCodable(true))
    }

    @Test func nullEquality() {
        #expect(AnyCodable(NSNull()) == AnyCodable(NSNull()))
    }

    @Test func arrayEquality() {
        let a = AnyCodable([1, 2, 3] as [Any])
        let b = AnyCodable([1, 2, 3] as [Any])
        #expect(a == b)
    }

    @Test func dictEquality() {
        let a = AnyCodable(["key": "value"] as [String: Any])
        let b = AnyCodable(["key": "value"] as [String: Any])
        #expect(a == b)
    }

    @Test func differentTypesNotEqual() {
        #expect(AnyCodable(1.0) != AnyCodable("1.0"))
    }
}

// MARK: - Error Sanitization Tests

@Suite("Error Message Sanitization")
struct ErrorSanitizationTests {
    @Test func shortMessageUnchanged() {
        let msg = "Not found"
        #expect(sanitizeErrorMessage(msg) == msg)
    }

    @Test func longMessageTruncated() {
        let longMsg = String(repeating: "a", count: 1000)
        let sanitized = sanitizeErrorMessage(longMsg)
        #expect(sanitized.count == 503) // 500 + "..."
        #expect(sanitized.hasSuffix("..."))
    }

    @Test func malformedJsonReturnsUnknown() {
        let data = "not json at all".data(using: .utf8)!
        let error = parseAPIError(statusCode: 500, data: data)
        if case .unknown(let code, _, _) = error {
            #expect(code == 500)
        } else {
            Issue.record("Expected unknown error for malformed JSON")
        }
    }

    @Test func emptyDataReturnsUnknown() {
        let data = Data()
        let error = parseAPIError(statusCode: 500, data: data)
        if case .unknown(let code, _, _) = error {
            #expect(code == 500)
        } else {
            Issue.record("Expected unknown error for empty data")
        }
    }
}

// MARK: - Upload Validation Tests

@Suite("Upload Validation", .serialized)
struct UploadValidationTests: @unchecked Sendable {
    @Test func rejectsEmptyImageData() async {
        let http = makeTestHTTPClient()
        let resource = ImageResource(http: http)
        let request = UploadImageRequest(purpose: "icon", filename: "test.png", data: "")
        await #expect(throws: PassFastError.self) {
            _ = try await resource.upload(request)
        }
    }

    @Test func rejectsInvalidBase64ImageData() async {
        let http = makeTestHTTPClient()
        let resource = ImageResource(http: http)
        let request = UploadImageRequest(purpose: "icon", filename: "test.png", data: "not-valid-base64!!!")
        await #expect(throws: PassFastError.self) {
            _ = try await resource.upload(request)
        }
    }

    @Test func rejectsEmptyCertData() async {
        let http = makeTestHTTPClient()
        let resource = CertificateResource(http: http)
        let request = UploadCertificateRequest(certType: .wwdr, certData: "")
        await #expect(throws: PassFastError.self) {
            _ = try await resource.upload(request)
        }
    }

    @Test func rejectsEmptyP12Data() async {
        let http = makeTestHTTPClient()
        let resource = CertificateResource(http: http)
        let request = UploadP12Request(p12Data: "")
        await #expect(throws: PassFastError.self) {
            _ = try await resource.uploadP12(request)
        }
    }

    @Test func rejectsInvalidBase64P12Data() async {
        let http = makeTestHTTPClient()
        let resource = CertificateResource(http: http)
        let request = UploadP12Request(p12Data: "not-valid-base64!!!")
        await #expect(throws: PassFastError.self) {
            _ = try await resource.uploadP12(request)
        }
    }
}

// MARK: - Sensitive Data Protection Tests

@Suite("Sensitive Data Protection")
struct SensitiveDataTests {
    @Test func apiKeyCreatedRedactsRawKey() throws {
        let json = """
        {
            "id": "key-1", "organization_id": "org-1", "name": "Test",
            "key_type": "secret", "key_prefix": "sk_live_",
            "scopes": ["read"], "raw_key": "sk_live_super_secret_key",
            "expires_at": null, "is_active": true, "created_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let key = try JSONDecoder().decode(ApiKeyCreated.self, from: json)
        let desc = String(describing: key)
        #expect(!desc.contains("super_secret_key"))
        #expect(desc.contains("[REDACTED]"))
    }

    @Test func uploadP12RedactsPassword() {
        let req = UploadP12Request(p12Data: "dGVzdA==", password: "my-secret-password")
        let desc = String(describing: req)
        #expect(!desc.contains("my-secret-password"))
        #expect(desc.contains("[REDACTED]"))
    }

    @Test func organizationRedactsWebhookSecret() throws {
        let json = """
        {
            "id": "org-1", "name": "Test Org", "slug": "test",
            "apns_key_id": null, "billing_plan": "free",
            "monthly_pass_limit": 100, "features": null,
            "is_active": true, "webhook_secret": "whsec_super_secret",
            "created_at": "2026-01-01T00:00:00Z", "updated_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let org = try JSONDecoder().decode(Organization.self, from: json)
        let desc = String(describing: org)
        #expect(!desc.contains("whsec_super_secret"))
        #expect(desc.contains("[REDACTED]"))
    }
}

// MARK: - Webhook Verifier Tests

#if canImport(CryptoKit)
import CryptoKit

@Suite("Webhook Verification")
struct WebhookVerifierTests {
    @Test func validSignatureAccepted() {
        let secret = "test-secret"
        let payload = "test-payload"
        let verifier = WebhookVerifier(secret: secret)

        // Compute expected HMAC
        let key = SymmetricKey(data: secret.data(using: .utf8)!)
        let mac = HMAC<SHA256>.authenticationCode(for: payload.data(using: .utf8)!, using: key)
        let signature = mac.map { String(format: "%02x", $0) }.joined()

        #expect(verifier.verify(payload: payload, signature: signature))
    }

    @Test func invalidSignatureRejected() {
        let verifier = WebhookVerifier(secret: "test-secret")
        #expect(!verifier.verify(payload: "test-payload", signature: "invalid-signature"))
    }

    @Test func wrongSecretRejected() {
        let secret = "correct-secret"
        let payload = "test-payload"

        let key = SymmetricKey(data: secret.data(using: .utf8)!)
        let mac = HMAC<SHA256>.authenticationCode(for: payload.data(using: .utf8)!, using: key)
        let signature = mac.map { String(format: "%02x", $0) }.joined()

        let wrongVerifier = WebhookVerifier(secret: "wrong-secret")
        #expect(!wrongVerifier.verify(payload: payload, signature: signature))
    }

    @Test func emptyPayloadWorks() {
        let verifier = WebhookVerifier(secret: "secret")
        let key = SymmetricKey(data: "secret".data(using: .utf8)!)
        let mac = HMAC<SHA256>.authenticationCode(for: Data(), using: key)
        let signature = mac.map { String(format: "%02x", $0) }.joined()
        #expect(verifier.verify(payload: Data(), signature: signature))
    }
}
#endif
