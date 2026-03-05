import Foundation
#if canImport(PassKit)
import PassKit
#endif

/// Manages passes — generate, list, get, update, void, download.
public struct PassResource: Sendable {
    let http: HTTPClient

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

    /// Delete a pass by ID.
    public func delete(_ passId: String) async throws -> DeletePassResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(passId)
        return try await http.request(method: "DELETE", path: "/manage-passes/\(safeId)")
    }

    /// Get a pass by serial number.
    public func getBySerial(_ serialNumber: String) async throws -> Pass {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        return try await http.request(method: "GET", path: "/manage-passes/serial/\(safeSN)")
    }

    /// Update a pass by serial number.
    public func updateBySerial(_ serialNumber: String, _ request: UpdatePassRequest) async throws -> UpdatePassResponse {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        return try await http.request(method: "PATCH", path: "/manage-passes/serial/\(safeSN)", body: request)
    }

    /// Delete a pass by serial number.
    public func deleteBySerial(_ serialNumber: String) async throws -> DeletePassResponse {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        return try await http.request(method: "DELETE", path: "/manage-passes/serial/\(safeSN)")
    }

    /// Download the .pkpass binary by serial number.
    public func downloadBySerial(_ serialNumber: String) async throws -> Data {
        let safeSN = try RequestBuilder.sanitizePathComponent(serialNumber)
        let raw = try await http.requestRaw(method: "GET", path: "/manage-passes/serial/\(safeSN)/download")
        return raw.data
    }
}
