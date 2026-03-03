import Testing
import Foundation
@testable import PassFast

@Suite("Error Parsing")
struct ErrorParsingTests {

    // MARK: - Nested format (existing)

    @Test func validation400() {
        let data = #"{"error":{"code":"validation","message":"Field required","details":{"field":"name"}}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 400, data: data)
        guard case .validation(let msg, let details) = error else {
            Issue.record("Expected validation error"); return
        }
        #expect(msg == "Field required")
        #expect(details != nil)
    }

    @Test func authentication401() {
        let data = #"{"error":{"code":"auth","message":"Invalid API key"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 401, data: data)
        guard case .authentication(let msg) = error else {
            Issue.record("Expected authentication error"); return
        }
        #expect(msg == "Invalid API key")
    }

    @Test func permission403() {
        let data = #"{"error":{"code":"forbidden","message":"Access denied"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 403, data: data)
        guard case .permission(let msg) = error else {
            Issue.record("Expected permission error"); return
        }
        #expect(msg == "Access denied")
    }

    @Test func notFound404() {
        let data = #"{"error":{"code":"not_found","message":"Pass not found"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 404, data: data)
        guard case .notFound(let msg) = error else {
            Issue.record("Expected notFound error"); return
        }
        #expect(msg == "Pass not found")
    }

    @Test func conflict409() {
        let data = #"{"error":{"code":"conflict","message":"Already exists"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 409, data: data)
        guard case .conflict(let msg) = error else {
            Issue.record("Expected conflict error"); return
        }
        #expect(msg == "Already exists")
    }

    @Test func rateLimited429() {
        let data = #"{"error":{"code":"rate_limit","message":"Too many requests"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 429, data: data)
        guard case .rateLimited(let msg) = error else {
            Issue.record("Expected rateLimited error"); return
        }
        #expect(msg == "Too many requests")
    }

    @Test func server500() {
        let data = #"{"error":{"code":"internal","message":"Server error"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 500, data: data)
        guard case .server(let msg) = error else {
            Issue.record("Expected server error"); return
        }
        #expect(msg == "Server error")
    }

    @Test func webhookError502() {
        let data = #"{"error":{"code":"webhook","message":"Webhook failed"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 502, data: data)
        guard case .webhookError(let msg) = error else {
            Issue.record("Expected webhookError"); return
        }
        #expect(msg == "Webhook failed")
    }

    @Test func unknownStatusCode() {
        let data = #"{"error":{"code":"teapot","message":"I am a teapot"}}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 418, data: data)
        guard case .unknown(let code, let errCode, let msg) = error else {
            Issue.record("Expected unknown error"); return
        }
        #expect(code == 418)
        #expect(errCode == "teapot")
        #expect(msg == "I am a teapot")
    }

    // MARK: - Flat format

    @Test func flatErrorFormat404() {
        let data = #"{"error":"not_found","message":"Pass not found"}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 404, data: data)
        guard case .notFound(let msg) = error else {
            Issue.record("Expected notFound error for flat format"); return
        }
        #expect(msg == "Pass not found")
    }

    @Test func flatErrorFormatWithCode() {
        let data = #"{"error":"validation_error","code":"invalid_field","message":"Name is required"}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 400, data: data)
        guard case .validation(let msg, _) = error else {
            Issue.record("Expected validation error for flat format"); return
        }
        #expect(msg == "Name is required")
    }

    @Test func flatErrorFormatNoMessage() {
        let data = #"{"error":"unauthorized"}"#.data(using: .utf8)!
        let error = parseAPIError(statusCode: 401, data: data)
        guard case .authentication(let msg) = error else {
            Issue.record("Expected authentication error for flat format without message"); return
        }
        #expect(msg == "unauthorized")
    }

    // MARK: - Edge cases

    @Test func invalidJSON() {
        let data = "not json".data(using: .utf8)!
        let error = parseAPIError(statusCode: 400, data: data)
        guard case .unknown(let code, _, let msg) = error else {
            Issue.record("Expected unknown error for bad JSON"); return
        }
        #expect(code == 400)
        #expect(msg == "HTTP 400")
    }

    @Test func emptyData() {
        let error = parseAPIError(statusCode: 500, data: Data())
        guard case .unknown(let code, _, _) = error else {
            Issue.record("Expected unknown error for empty data"); return
        }
        #expect(code == 500)
    }

    @Test func errorDescription() {
        let error = PassFastError.authentication("Bad key")
        #expect(error.errorDescription == "Bad key")

        let networkErr = PassFastError.network(URLError(.notConnectedToInternet))
        #expect(networkErr.errorDescription?.contains("Network error") == true)

        let decodingErr = PassFastError.decodingError(URLError(.cannotParseResponse))
        #expect(decodingErr.errorDescription?.contains("Decoding error") == true)
    }
}
