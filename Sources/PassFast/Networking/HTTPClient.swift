import Foundation

actor HTTPClient {
    let configuration: Configuration
    private let session: URLSession
    private let requestBuilder: RequestBuilder

    init(configuration: Configuration, sessionConfiguration: URLSessionConfiguration? = nil) {
        self.configuration = configuration
        self.session = URLSession(configuration: sessionConfiguration ?? .ephemeral)
        self.requestBuilder = RequestBuilder(configuration: configuration)
    }

    // MARK: - JSON responses

    func request<T: Decodable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws -> T {
        let urlRequest = try requestBuilder.buildRequest(
            method: method,
            path: path,
            queryItems: queryItems,
            body: body,
            additionalHeaders: additionalHeaders
        )

        let (data, response) = try await perform(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PassFastError.unknown(statusCode: 0, code: "no_response", message: "No HTTP response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw PassFastError.decodingError(error)
        }
    }

    // MARK: - Void responses

    func request(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws {
        let urlRequest = try requestBuilder.buildRequest(
            method: method,
            path: path,
            queryItems: queryItems,
            body: body,
            additionalHeaders: additionalHeaders
        )

        let (data, response) = try await perform(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PassFastError.unknown(statusCode: 0, code: "no_response", message: "No HTTP response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    // MARK: - Raw data responses (for binary .pkpass downloads)

    struct RawResponse {
        let data: Data
        let httpResponse: HTTPURLResponse
    }

    func requestRaw(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws -> RawResponse {
        let urlRequest = try requestBuilder.buildRequest(
            method: method,
            path: path,
            queryItems: queryItems,
            body: body,
            additionalHeaders: additionalHeaders
        )

        let (data, response) = try await perform(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PassFastError.unknown(statusCode: 0, code: "no_response", message: "No HTTP response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw parseAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        return RawResponse(data: data, httpResponse: httpResponse)
    }

    // MARK: - Private

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw PassFastError.network(error)
        }
    }
}
