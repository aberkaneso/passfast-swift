import Foundation
#if canImport(PassKit)
import PassKit
#endif

/// Manages passes — generate, list, get, update, void, download.
public struct PassResource: Sendable {
    let http: HTTPClient

    // MARK: - Generate (Apple — returns binary .pkpass)

    /// Generate a .pkpass binary. Returns passId, raw pkpass data, and whether it already existed.
    public func generate(_ request: GeneratePassRequest) async throws -> GeneratePassResponse {
        let raw = try await http.requestRaw(
            method: "POST",
            path: "/generate-pass",
            body: request
        )

        let passId = raw.httpResponse.value(forHTTPHeaderField: "X-Pass-Id") ?? ""
        let existed = raw.httpResponse.value(forHTTPHeaderField: "X-Pass-Existed") == "true"

        return GeneratePassResponse(passId: passId, pkpassData: raw.data, existed: existed)
    }

    #if canImport(PassKit)
    /// Generate a pass and return a `PKPass` ready for Apple Wallet.
    public func generatePKPass(_ request: GeneratePassRequest) async throws -> (PKPass, String) {
        let response = try await generate(request)
        let pkPass = try PKPass(data: response.pkpassData)
        return (pkPass, response.passId)
    }
    #endif

    // MARK: - Generate (Google — returns JSON)

    /// Generate a Google Wallet pass. Returns a JSON response with a `saveUrl`.
    public func generateGoogle(_ request: GeneratePassRequest) async throws -> GoogleGenerateResponse {
        var req = request
        req.walletType = "google"
        return try await http.request(method: "POST", path: "/generate-pass", body: req)
    }

    // MARK: - Generate (Dual — returns JSON with both)

    /// Generate both Apple and Google passes in a single call.
    public func generateDual(_ request: GeneratePassRequest) async throws -> DualGenerateResponse {
        var req = request
        req.walletType = "both"
        return try await http.request(method: "POST", path: "/generate-pass", body: req)
    }

    // MARK: - List / Get / Download / Update / Void

    /// List passes with optional filters.
    public func list(_ params: ListPassesParams? = nil) async throws -> [Pass] {
        try await http.request(
            method: "GET",
            path: "/manage-passes",
            queryItems: params?.queryItems
        )
    }

    /// Get a single pass by ID.
    public func get(_ passId: String) async throws -> Pass {
        let safeId = try RequestBuilder.sanitizePathComponent(passId)
        return try await http.request(method: "GET", path: "/manage-passes/\(safeId)")
    }

    /// Download the .pkpass binary for a pass.
    public func download(_ passId: String) async throws -> Data {
        let safeId = try RequestBuilder.sanitizePathComponent(passId)
        let raw = try await http.requestRaw(
            method: "GET",
            path: "/manage-passes/\(safeId)/download"
        )
        return raw.data
    }

    /// Update a pass (data, push_update). Triggers push notification.
    public func update(_ passId: String, _ request: UpdatePassRequest) async throws -> UpdatePassResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(passId)
        return try await http.request(
            method: "PATCH",
            path: "/manage-passes/\(safeId)",
            body: request
        )
    }

    /// Void (invalidate) a pass. Triggers push notification.
    public func void(_ passId: String) async throws -> VoidPassResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(passId)
        return try await http.request(method: "POST", path: "/manage-passes/\(safeId)/void")
    }

    // MARK: - Serial Number Operations

    /// Get a pass by serial number.
    public func getBySerial(_ serialNumber: String, walletType: String? = nil) async throws -> Pass {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        return try await http.request(
            method: "GET",
            path: "/manage-passes/serial/\(safeSN)",
            queryItems: walletTypeQueryItems(walletType)
        )
    }

    /// Update a pass by serial number.
    public func updateBySerial(_ serialNumber: String, _ request: UpdatePassRequest, walletType: String? = nil) async throws -> UpdatePassResponse {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        return try await http.request(
            method: "PATCH",
            path: "/manage-passes/serial/\(safeSN)",
            queryItems: walletTypeQueryItems(walletType),
            body: request
        )
    }

    /// Void (invalidate) a pass by serial number.
    public func voidBySerial(_ serialNumber: String, walletType: String? = nil) async throws -> VoidPassResponse {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        return try await http.request(
            method: "POST",
            path: "/manage-passes/serial/\(safeSN)/void",
            queryItems: walletTypeQueryItems(walletType)
        )
    }

    /// Download the .pkpass binary by serial number.
    public func downloadBySerial(_ serialNumber: String, walletType: String? = nil) async throws -> Data {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        let raw = try await http.requestRaw(
            method: "GET",
            path: "/manage-passes/serial/\(safeSN)/download",
            queryItems: walletTypeQueryItems(walletType)
        )
        return raw.data
    }

    // MARK: - Private

    private func walletTypeQueryItems(_ walletType: String?) -> [URLQueryItem]? {
        guard let walletType else { return nil }
        return [URLQueryItem(name: "wallet_type", value: walletType)]
    }
}
