import Foundation

/// Manages organization members — list, invite, change role, remove.
public struct MemberResource: Sendable {
    let http: HTTPClient
    private let orgId: String?

    init(http: HTTPClient, orgId: String? = nil) {
        self.http = http
        self.orgId = orgId
    }

    private var orgHeaders: [String: String]? {
        guard let orgId else { return nil }
        return ["X-Org-Id": orgId]
    }

    /// List all organization members.
    public func list() async throws -> [Member] {
        try await http.request(method: "GET", path: "/manage-members", additionalHeaders: orgHeaders)
    }

    /// List pending invitations.
    public func listInvitations() async throws -> [Invitation] {
        try await http.request(method: "GET", path: "/manage-members/invitations", additionalHeaders: orgHeaders)
    }

    /// Invite a new member by email.
    public func invite(_ request: InviteMemberRequest) async throws -> Invitation {
        try await http.request(method: "POST", path: "/manage-members/invite", body: request, additionalHeaders: orgHeaders)
    }

    /// Accept an invitation using a token.
    public func acceptInvitation(_ request: AcceptInvitationRequest) async throws -> AcceptInvitationResponse {
        try await http.request(method: "POST", path: "/manage-members/accept", body: request, additionalHeaders: orgHeaders)
    }

    /// Revoke a pending invitation.
    public func revokeInvitation(_ invitationId: String) async throws -> RevokeInvitationResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(invitationId)
        return try await http.request(method: "DELETE", path: "/manage-members/invitations/\(safeId)", additionalHeaders: orgHeaders)
    }

    /// Change a member's role.
    public func changeRole(_ userId: String, _ request: ChangeRoleRequest) async throws -> ChangeRoleResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(userId)
        return try await http.request(method: "PATCH", path: "/manage-members/\(safeId)", body: request, additionalHeaders: orgHeaders)
    }

    /// Remove a member from the organization.
    public func remove(_ userId: String) async throws -> RemoveMemberResponse {
        let safeId = try RequestBuilder.sanitizePathComponent(userId)
        return try await http.request(method: "DELETE", path: "/manage-members/\(safeId)", additionalHeaders: orgHeaders)
    }
}
