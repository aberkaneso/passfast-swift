import Foundation
@testable import PassFast

func makeTestHTTPClient(
    apiKey: String = "sk_live_test",
    baseURL: URL? = nil,
    orgId: String? = "org-test",
    appId: String? = "app-test",
    timeoutInterval: TimeInterval = 10
) -> HTTPClient {
    let config = Configuration(
        apiKey: apiKey,
        baseURL: baseURL,
        orgId: orgId,
        appId: appId,
        timeoutInterval: timeoutInterval
    )
    let sessionConfig = URLSessionConfiguration.ephemeral
    sessionConfig.protocolClasses = [MockURLProtocol.self]
    return HTTPClient(configuration: config, sessionConfiguration: sessionConfig)
}

func mockResponse(
    url: String = "https://example.com",
    statusCode: Int = 200,
    json: String
) -> (HTTPURLResponse, Data) {
    let response = HTTPURLResponse(
        url: URL(string: url)!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    )!
    return (response, json.data(using: .utf8)!)
}

func mockResponse(
    url: String = "https://example.com",
    statusCode: Int = 200,
    data: Data = Data(),
    headers: [String: String] = [:]
) -> (HTTPURLResponse, Data) {
    let response = HTTPURLResponse(
        url: URL(string: url)!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: headers
    )!
    return (response, data)
}
