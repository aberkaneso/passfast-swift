# PassFast Swift SDK

## Overview
Swift SDK for the PassFast API — manages Apple Wallet passes, templates, certificates, images, API keys, members, and webhook events.

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
  Networking/
    HTTPClient.swift      — URL session HTTP layer
    RequestBuilder.swift  — URL/request construction
  Resources/              — One file per API resource (CRUD methods)
    PassResource.swift, TemplateResource.swift, MemberResource.swift,
    ImageResource.swift, CertificateResource.swift, APIKeyResource.swift,
    OrganizationResource.swift, WebhookEventResource.swift
  UI/
    AddToWalletButton.swift, PassSheet.swift
Tests/PassFastTests/
  AllMockTests.swift      — Parent suite (.serialized) for mock tests
  TestHelpers.swift       — makeTestHTTPClient(), mockResponse() helpers
  MockURLProtocol.swift   — URLProtocol mock for HTTP tests
  ModelCodingTests.swift  — Encoding/decoding unit tests
  PassResourceTests.swift, SimpleResourceTests.swift,
  TemplateResourceTests.swift, OrganizationResourceTests.swift,
  RequestBuilderTests.swift, ConfigurationTests.swift,
  ErrorParsingTests.swift, PassFastTests.swift
```

## Key Conventions
- **CodingKeys**: Most models use `snake_case` JSON keys mapped to `camelCase` Swift properties. Exception: `PassLocation.relevantText` uses camelCase JSON key `"relevantText"`
- **Resource pattern**: Each resource struct holds an `HTTPClient` ref, methods are `async throws`
- **Path params**: Always use `RequestBuilder.sanitizePathComponent()` for user-provided path segments
- **Query params**: `ListXxxParams` structs have a `queryItems` computed property returning `[URLQueryItem]`
- **Request types**: Conform to `Encodable, Sendable`; response/model types to `Codable, Sendable`. Exception: `UploadImageRequest` is `Sendable` only (uses multipart upload, not JSON)
- **Image upload**: Uses `multipart/form-data` via `HTTPClient.requestMultipart()`, not JSON
- **Delete methods**: Return typed response structs (e.g. `DeleteTemplateResponse`, `DeleteImageResponse`), not `Void`
- **Mock tests**: All tests using `MockURLProtocol` must be nested under `AllMockTests` (serialized suite) to avoid races
- **Test style**: Use `#expect()` assertions, not XCTAssert

## Commands
- **Build**: `swift build`
- **Test**: `swift test`

## OpenAPI Spec
The SDK mirrors an OpenAPI spec. When syncing:
1. Add/update models in `Types.swift`
2. Update resource methods in `Resources/`
3. Add corresponding tests in the appropriate test file
4. Run `swift build` then `swift test` to verify
