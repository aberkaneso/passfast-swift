# PassFast Swift SDK

## Overview
Swift SDK for the PassFast API — manages Apple Wallet and Google Wallet passes and webhook events.

## Tech Stack
- **Language**: Swift 5 (Swift Tools 6.0)
- **Platforms**: iOS 16+, macOS 13+
- **Testing**: Swift Testing framework (`@Test`, `@Suite`, `#expect`)
- **Dependencies**: `swift-testing` (only for tests)
- **No external runtime dependencies**

## Project Structure
```
Sources/PassFast/
  PassFastClient.swift    — Main client entry point
  Types.swift             — All models, request/response types, enums
  AnyCodable.swift        — Type-erased Codable for arbitrary JSON
  Configuration.swift     — API key, base URL, org/app IDs config
  Errors.swift            — PassFastError enum
  WebhookVerifier.swift   — HMAC-SHA256 webhook signature verification
  Networking/
    HTTPClient.swift      — URL session HTTP layer
    RequestBuilder.swift  — URL/request construction
  Resources/
    PassResource.swift    — Pass generation, listing, updating, voiding, downloading
    WebhookEventResource.swift — Webhook event delivery history
  UI/
    AddToWalletButton.swift, PassSheet.swift
Tests/PassFastTests/
  AllMockTests.swift      — Parent suite (.serialized) for mock tests
  TestHelpers.swift       — makeTestHTTPClient(), mockResponse() helpers
  MockURLProtocol.swift   — URLProtocol mock for HTTP tests
  ModelCodingTests.swift  — Encoding/decoding unit tests
  PassResourceTests.swift — Pass resource method tests
  WebhookEventResourceTests.swift — Webhook event resource tests
  RequestBuilderTests.swift, ConfigurationTests.swift,
  ErrorParsingTests.swift, SecurityTests.swift, PassFastTests.swift
```

## Key Conventions
- **CodingKeys**: Most models use `snake_case` JSON keys mapped to `camelCase` Swift properties. Exception: `PassLocation.relevantText` uses camelCase JSON key `"relevantText"`
- **Resource pattern**: Each resource struct holds an `HTTPClient` ref, methods are `async throws`
- **Path params**: Always use `RequestBuilder.sanitizePathComponent()` for user-provided path segments
- **Query params**: `ListXxxParams` structs have a `queryItems` computed property returning `[URLQueryItem]`
- **Request types**: Conform to `Encodable, Sendable`; response/model types to `Codable, Sendable`
- **Google Wallet**: `GeneratePassRequest.walletType` accepts `"apple"`, `"google"`, or `"both"`. Use `generateGoogle()` / `generateDual()` for JSON responses, `generate()` for Apple binary .pkpass
- **Serial number methods**: `getBySerial`, `updateBySerial`, `voidBySerial`, `downloadBySerial` accept optional `walletType` parameter
- **Mock tests**: All tests using `MockURLProtocol` must be nested under `AllMockTests` (serialized suite) to avoid races
- **Test style**: Use `#expect()` assertions, not XCTAssert

## Commands
- **Build**: `swift build`
- **Test**: `swift test`

## OpenAPI Spec
The SDK mirrors the Passes and Webhook Events sections of the OpenAPI spec. When syncing:
1. Add/update models in `Types.swift`
2. Update resource methods in `Resources/`
3. Add corresponding tests in the appropriate test file
4. Run `swift build` then `swift test` to verify
