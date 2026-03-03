# PassFast Swift SDK

Official Swift SDK for the [PassFast](https://passfa.st) Apple Wallet Pass platform.

- **Swift concurrency** — all methods are `async throws`
- **PKPass integration** — generate passes ready for Apple Wallet
- **SwiftUI components** — `AddToWalletButton` and `PassSheet`
- **Zero dependencies** — uses `URLSession` only
- iOS 16+ / macOS 13+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aberkaneso/passfast-swift", from: "1.0.0"),
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
    baseURL: URL(string: "https://your-instance.supabase.co/functions/v1"), // custom
    orgId: "org-...",   // required for JWT auth
    appId: "app-...",   // required if org has multiple apps
    timeoutInterval: 15 // seconds (default: 30)
)
```

## Resources

### Passes

```swift
// Generate raw .pkpass data
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

// List passes
let passes = try await client.passes.list(ListPassesParams(status: .active, limit: 10))

// Update (triggers push notification)
let result = try await client.passes.update(passId, UpdatePassRequest(
    data: ["points": "2000"]
))
// result.pushSent

// Void a pass
let voided = try await client.passes.void(passId)

// Download .pkpass binary
let data = try await client.passes.download(passId)
```

### Templates

```swift
let template = try await client.templates.create(.init(
    name: "Loyalty Card",
    passStyle: .storeCard,
    structure: ["headerFields": [["key": "name", "label": "Name", "value": ""]]]
))

try await client.templates.publish(template.id)
let templates = try await client.templates.list()
```

### Organization & Apps

```swift
let org = try await client.organization.get()
let apps = try await client.organization.listApps()

let app = try await client.organization.createApp(.init(
    name: "My App",
    appleTeamId: "TEAMID",
    passTypeIdentifier: "pass.com.example"
))

// Regenerate webhook secret
let updated = try await client.organization.updateApp(app.id, .init(
    regenerateWebhookSecret: true
))
print(updated.webhookSecretRaw!) // shown once
```

### API Keys

```swift
let created = try await client.apiKeys.create(.init(
    name: "iOS Key",
    keyType: .publishable
))
print(created.rawKey) // shown once

let keys = try await client.apiKeys.list()
try await client.apiKeys.revoke(created.id)
```

### Members

```swift
let response = try await client.members.list()
// response.members, response.invitations

try await client.members.invite(.init(email: "dev@example.com", role: .editor))
try await client.members.changeRole(userId, .init(role: .admin))
try await client.members.remove(userId)
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
