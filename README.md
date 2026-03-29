# PassFast Swift SDK

Official Swift SDK for the [PassFast](https://passfa.st) Apple Wallet and Google Wallet pass platform.

- **Swift concurrency** — all methods are `async throws`
- **Apple & Google Wallet** — generate passes for both platforms
- **PKPass integration** — generate passes ready for Apple Wallet
- **Pass Sharing** — create public share links for pass distribution
- **SwiftUI components** — `AddToWalletButton` and `PassSheet`
- **Zero dependencies** — uses `URLSession` only
- iOS 16+ / macOS 13+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aberkaneso/passfast-swift", from: "2.0.0"),
]
```

Or in Xcode: File > Add Package Dependencies > paste the URL.

## Quick Start

```swift
import PassFast

let client = PassFastClient(apiKey: "pk_live_...")

// Generate a pass and get PKPass for Apple Wallet
let (pass, passId) = try await client.passes.generatePKPass(.init(
    templateId: "...",
    serialNumber: "MBR-001",
    data: ["name": "Jane Doe", "points": "1250"]
))

// Present Add to Wallet sheet
PassSheet(pass: pass)
```

## Configuration

```swift
let client = PassFastClient(
    apiKey: "sk_live_...",
    orgId: "org-...",   // required for JWT auth
    appId: "app-...",   // required if org has multiple apps
    timeoutInterval: 15 // seconds (default: 30)
)
```

## Resources

### Passes

```swift
// Generate Apple .pkpass binary
let response = try await client.passes.generate(.init(
    templateId: "...",
    serialNumber: "MBR-001",
    data: ["name": "Jane Doe"],
    getOrCreate: true  // idempotent
))
// response.passId, response.pkpassData, response.existed

// Generate PKPass directly (iOS)
let (pkPass, passId) = try await client.passes.generatePKPass(.init(
    templateId: "...",
    serialNumber: "MBR-001",
    data: ["name": "Jane"]
))

// Generate Google Wallet pass
let google = try await client.passes.generateGoogle(.init(
    templateId: "...",
    serialNumber: "MBR-001",
    data: ["name": "Jane"]
))
// google.saveUrl — Google Wallet save URL

// Generate both Apple and Google passes
let dual = try await client.passes.generateDual(.init(
    templateId: "...",
    serialNumber: "MBR-001",
    data: ["name": "Jane"]
))
// dual.apple?.downloadUrl, dual.google?.saveUrl, dual.warnings

// List passes
let passes = try await client.passes.list(ListPassesParams(status: .active, limit: 10))

// List passes filtered by wallet type
let googlePasses = try await client.passes.list(ListPassesParams(walletType: "google"))

// Get, download, update, void by ID
let pass = try await client.passes.get(passId)
let data = try await client.passes.download(passId)
let result = try await client.passes.update(passId, UpdatePassRequest(
    data: ["points": "2000"],
    pushUpdate: true
))
let voided = try await client.passes.void(passId)

// Serial number lookups (with optional wallet type)
let passBySN = try await client.passes.getBySerial("MBR-001")
let updated = try await client.passes.updateBySerial("MBR-001", UpdatePassRequest(data: ["points": "3000"]))
let voidedBySN = try await client.passes.voidBySerial("MBR-001")
let dataBySN = try await client.passes.downloadBySerial("MBR-001")

// Specify wallet type for serial lookups (when both Apple and Google exist)
let googlePass = try await client.passes.getBySerial("MBR-001", walletType: "google")
```

### Pass Sharing

```swift
// Create a share token for a pass
let shareToken = try await client.sharing.createShareToken(
    CreateShareTokenRequest(passId: passId)
)
// shareToken.shareToken, shareToken.shareUrl

// Get public metadata for a shared pass (no auth required)
let metadata = try await client.sharing.getMetadata(shareToken.shareToken)
// metadata.serialNumber, metadata.hasApple, metadata.hasGoogle, metadata.templateName

// Download shared .pkpass (no auth required)
let sharedData = try await client.sharing.download(shareToken.shareToken)
```

### Webhook Events

```swift
let events = try await client.webhookEvents.list(ListWebhookEventsParams(
    eventType: .passCreated,
    deliveryStatus: .failed
))
```

## SwiftUI Components

### AddToWalletButton

A native "Add to Apple Wallet" button that handles pass generation and presentation.

```swift
import PassFast

struct ContentView: View {
    let client = PassFastClient(apiKey: "pk_live_...")

    var body: some View {
        AddToWalletButton {
            let (pass, _) = try await client.passes.generatePKPass(.init(
                templateId: "...",
                serialNumber: "MBR-001",
                data: ["name": "Jane Doe"]
            ))
            return pass
        }
    }
}
```

### PassSheet

Present the system "Add to Wallet" sheet for a `PKPass`:

```swift
@State private var showPass = false
@State private var pkPass: PKPass?

var body: some View {
    Button("Add Pass") {
        Task {
            let (pass, _) = try await client.passes.generatePKPass(...)
            pkPass = pass
            showPass = true
        }
    }
    .sheet(isPresented: $showPass) {
        if let pkPass {
            PassSheet(pass: pkPass) {
                showPass = false
            }
        }
    }
}
```

## Error Handling

```swift
do {
    try await client.passes.generate(...)
} catch let error as PassFastError {
    switch error {
    case .authentication(let msg):
        print("Auth failed: \(msg)")         // 401
    case .notFound(let msg):
        print("Not found: \(msg)")           // 404
    case .validation(let msg, let details):
        print("Invalid: \(msg)")             // 400
    case .webhookError(let msg):
        print("Webhook: \(msg)")             // 502
    default:
        print(error.localizedDescription)
    }
}
```

## License

MIT
