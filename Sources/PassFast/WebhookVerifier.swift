import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/// Verifies incoming webhook payloads using HMAC-SHA256 signatures.
///
/// ```swift
/// let verifier = WebhookVerifier(secret: "whsec_...")
/// let isValid = verifier.verify(payload: bodyData, signature: headerSignature)
/// ```
public struct WebhookVerifier: Sendable {
    private let secret: String

    /// Create a webhook verifier with the webhook secret from your organization/app settings.
    public init(secret: String) {
        self.secret = secret
    }

    #if canImport(CryptoKit)
    /// Verify a webhook payload against the provided HMAC-SHA256 signature.
    ///
    /// - Parameters:
    ///   - payload: The raw request body data.
    ///   - signature: The signature from the `X-Webhook-Signature` header.
    /// - Returns: `true` if the signature is valid.
    public func verify(payload: Data, signature: String) -> Bool {
        guard let keyData = secret.data(using: .utf8) else { return false }
        let key = SymmetricKey(data: keyData)
        let mac = HMAC<SHA256>.authenticationCode(for: payload, using: key)
        let expectedSignature = mac.map { String(format: "%02x", $0) }.joined()
        return constantTimeEqual(expectedSignature, signature)
    }

    /// Verify a webhook payload string against the provided HMAC-SHA256 signature.
    ///
    /// - Parameters:
    ///   - payload: The raw request body as a UTF-8 string.
    ///   - signature: The signature from the `X-Webhook-Signature` header.
    /// - Returns: `true` if the signature is valid.
    public func verify(payload: String, signature: String) -> Bool {
        guard let data = payload.data(using: .utf8) else { return false }
        return verify(payload: data, signature: signature)
    }

    /// Constant-time string comparison to prevent timing attacks.
    private func constantTimeEqual(_ a: String, _ b: String) -> Bool {
        let aBytes = Array(a.utf8)
        let bBytes = Array(b.utf8)
        guard aBytes.count == bBytes.count else { return false }
        var result: UInt8 = 0
        for (x, y) in zip(aBytes, bBytes) {
            result |= x ^ y
        }
        return result == 0
    }
    #endif
}
