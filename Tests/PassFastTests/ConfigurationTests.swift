import Testing
import Foundation
@testable import PassFast

@Suite("Configuration")
struct ConfigurationTests {
    @Test func defaultBaseURL() {
        let config = Configuration(apiKey: "test")
        #expect(config.baseURL.absoluteString.contains("supabase.co"))
    }

    @Test func customBaseURL() {
        let url = URL(string: "https://custom.api.com")!
        let config = Configuration(apiKey: "test", baseURL: url)
        #expect(config.baseURL == url)
    }

    @Test func defaultTimeout() {
        let config = Configuration(apiKey: "test")
        #expect(config.timeoutInterval == 30)
    }

    @Test func customTimeout() {
        let config = Configuration(apiKey: "test", timeoutInterval: 60)
        #expect(config.timeoutInterval == 60)
    }

    @Test func optionalFields() {
        let config = Configuration(apiKey: "key", orgId: "org-1", appId: "app-1")
        #expect(config.orgId == "org-1")
        #expect(config.appId == "app-1")

        let minimal = Configuration(apiKey: "key")
        #expect(minimal.orgId == nil)
        #expect(minimal.appId == nil)
    }
}
