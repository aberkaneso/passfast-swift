import Foundation

/// Manages templates — create, list, get, update, delete, publish.
public struct TemplateResource: Sendable {
    let http: HTTPClient

    /// Create a new template.
    public func create(_ request: CreateTemplateRequest) async throws -> Template {
        try await http.request(method: "POST", path: "/manage-templates", body: request)
    }

    /// List all templates.
    public func list() async throws -> [Template] {
        try await http.request(method: "GET", path: "/manage-templates")
    }

    /// Get a single template by ID.
    public func get(_ templateId: String) async throws -> Template {
        let safeId = try RequestBuilder.sanitizePathComponent(templateId)
        return try await http.request(method: "GET", path: "/manage-templates/\(safeId)")
    }

    /// Update a template.
    public func update(_ templateId: String, _ request: UpdateTemplateRequest) async throws -> Template {
        let safeId = try RequestBuilder.sanitizePathComponent(templateId)
        return try await http.request(method: "PATCH", path: "/manage-templates/\(safeId)", body: request)
    }

    /// Delete a template.
    public func delete(_ templateId: String) async throws {
        let safeId = try RequestBuilder.sanitizePathComponent(templateId)
        try await http.request(method: "DELETE", path: "/manage-templates/\(safeId)") as Void
    }

    /// Publish a template (makes it available for pass generation).
    public func publish(_ templateId: String) async throws -> Template {
        let safeId = try RequestBuilder.sanitizePathComponent(templateId)
        return try await http.request(method: "POST", path: "/manage-templates/\(safeId)/publish")
    }
}
