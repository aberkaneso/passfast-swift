import Testing

/// Parent suite that serializes all tests using MockURLProtocol.
/// This prevents cross-suite races on the shared static requestHandler.
@Suite("All Mock Tests", .serialized)
struct AllMockTests {}
