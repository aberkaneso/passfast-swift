import Foundation

/// Maximum length for server-provided error messages to prevent sensitive data leakage.
private let maxErrorMessageLength = 500

/// Truncates a server error message to a safe length.
func sanitizeErrorMessage(_ message: String) -> String {
    if message.count <= maxErrorMessageLength { return message }
    return String(message.prefix(maxErrorMessageLength)) + "..."
}

/// Error returned by the PassFast API.
public enum PassFastError: Error, LocalizedError, Sendable {
    case authentication(String)
    case permission(String)
    case notFound(String)
    case validation(String, details: AnyCodable?)
    case conflict(String)
    case rateLimited(String)
    case webhookError(String)
    case server(String)
    case network(Error)
    case decodingError(Error)
    case unknown(statusCode: Int, code: String, message: String)

    public var errorDescription: String? {
        switch self {
        case .authentication(let msg): return msg
        case .permission(let msg): return msg
        case .notFound(let msg): return msg
        case .validation(let msg, _): return msg
        case .conflict(let msg): return msg
        case .rateLimited(let msg): return msg
        case .webhookError(let msg): return msg
        case .server(let msg): return msg
        case .network(let err): return "Network error: \(err.localizedDescription)"
        case .decodingError(let err): return "Decoding error: \(err.localizedDescription)"
        case .unknown(_, _, let msg): return msg
        }
    }
}

// MARK: - Internal error response parsing

/// Nested format: `{ "error": { "code": "...", "message": "..." } }`
struct NestedAPIErrorBody: Decodable {
    let error: APIErrorDetail
}

struct APIErrorDetail: Decodable {
    let code: String
    let message: String
    let details: AnyCodable?
}

/// Flat format: `{ "error": "...", "code": "...", "message": "..." }`
struct FlatAPIErrorBody: Decodable {
    let error: String
    let code: String?
    let message: String?
    let details: AnyCodable?
}

func parseAPIError(statusCode: Int, data: Data) -> PassFastError {
    // Try nested format first: { "error": { "code": "...", "message": "..." } }
    if let body = try? JSONDecoder().decode(NestedAPIErrorBody.self, from: data) {
        return mapError(
            statusCode: statusCode,
            code: body.error.code,
            message: body.error.message,
            details: body.error.details
        )
    }

    // Fall back to flat format: { "error": "...", "message": "..." }
    if let body = try? JSONDecoder().decode(FlatAPIErrorBody.self, from: data) {
        let msg = body.message ?? body.error
        let code = body.code ?? body.error
        return mapError(
            statusCode: statusCode,
            code: code,
            message: msg,
            details: body.details
        )
    }

    return .unknown(statusCode: statusCode, code: "unknown", message: "HTTP \(statusCode)")
}

private func mapError(statusCode: Int, code: String, message: String, details: AnyCodable?) -> PassFastError {
    let msg = sanitizeErrorMessage(message)
    switch statusCode {
    case 400: return .validation(msg, details: details)
    case 401: return .authentication(msg)
    case 403: return .permission(msg)
    case 404: return .notFound(msg)
    case 409: return .conflict(msg)
    case 429: return .rateLimited(msg)
    case 502: return .webhookError(msg)
    default:
        if statusCode >= 500 { return .server(msg) }
        return .unknown(statusCode: statusCode, code: code, message: msg)
    }
}
