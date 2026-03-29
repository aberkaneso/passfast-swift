import Testing
import Foundation
@testable import PassFast

@Suite("RequestBuilder")
struct RequestBuilderTests {
    let builder = RequestBuilder(
        configuration: Configuration(
            apiKey: "sk_live_test123",
            orgId: "org-1",
            appId: "app-1",
            timeoutInterval: 15
        )
    )

    @Test func authorizationHeader() throws {
        let req = try builder.buildRequest(method: "GET", path: "/test")
        #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer sk_live_test123")
    }

    @Test func orgIdViaAdditionalHeaders() throws {
        let req = try builder.buildRequest(method: "GET", path: "/test", additionalHeaders: ["X-Org-Id": "org-1"])
        #expect(req.value(forHTTPHeaderField: "X-Org-Id") == "org-1")
    }

    @Test func orgIdNotSetGlobally() throws {
        let req = try builder.buildRequest(method: "GET", path: "/test")
        #expect(req.value(forHTTPHeaderField: "X-Org-Id") == nil)
    }

    @Test func appIdHeader() throws {
        let req = try builder.buildRequest(method: "GET", path: "/test")
        #expect(req.value(forHTTPHeaderField: "X-App-Id") == "app-1")
    }

    @Test func noOrgIdHeaderWhenNil() throws {
        let b = RequestBuilder(configuration: Configuration(apiKey: "key"))
        let req = try b.buildRequest(method: "GET", path: "/test")
        #expect(req.value(forHTTPHeaderField: "X-Org-Id") == nil)
    }

    @Test func noAppIdHeaderWhenNil() throws {
        let b = RequestBuilder(configuration: Configuration(apiKey: "key"))
        let req = try b.buildRequest(method: "GET", path: "/test")
        #expect(req.value(forHTTPHeaderField: "X-App-Id") == nil)
    }

    @Test func urlConstruction() throws {
        let req = try builder.buildRequest(method: "GET", path: "/manage-passes")
        #expect(req.url?.path.hasSuffix("/manage-passes") == true)
    }

    @Test func httpMethod() throws {
        let req = try builder.buildRequest(method: "POST", path: "/test")
        #expect(req.httpMethod == "POST")
    }

    @Test func queryParams() throws {
        let items = [URLQueryItem(name: "status", value: "active"), URLQueryItem(name: "limit", value: "10")]
        let req = try builder.buildRequest(method: "GET", path: "/test", queryItems: items)
        let url = req.url!.absoluteString
        #expect(url.contains("status=active"))
        #expect(url.contains("limit=10"))
    }

    @Test func bodyEncoding() throws {
        let body = UpdatePassRequest(data: ["name": "Acme"])
        let req = try builder.buildRequest(method: "PATCH", path: "/test", body: body)
        #expect(req.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let json = try JSONSerialization.jsonObject(with: req.httpBody!) as! [String: Any]
        #expect(json["data"] != nil)
    }

    @Test func noBodyNoContentType() throws {
        let req = try builder.buildRequest(method: "GET", path: "/test")
        #expect(req.value(forHTTPHeaderField: "Content-Type") == nil)
        #expect(req.httpBody == nil)
    }

    @Test func timeoutFromConfiguration() throws {
        let req = try builder.buildRequest(method: "GET", path: "/test")
        #expect(req.timeoutInterval == 15)
    }
}
