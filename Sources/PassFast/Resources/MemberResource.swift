import Foundation

/// Manages organization members — list, invite, change role, remove.
public struct MemberResource: Sendable {
    let http: HTTPClient

    /// List all organization members.
    public func list() async throws -> [Member] {
        try await http.request(method: "GET", path: "/manage-members")
    }

    /// List pending invitations.
    public func listInvitations() async throws -> [Invitation] {
        try await http.request(method: "GET", path: "/manage-members/invitations")
    }

    /// Invite a new member by email.
    public func invite(_ request: InviteMemberRequest) async throws -> Invitation {
        try await http.request(method: "POST", path: "/manage-members/invite", body: request)
    }

    /// Accept an invitation using a token.
    public func acceptInvitation(_ request: AcceptInvitationRequest) async throws -> AcceptInvitationResponse {
        try await http.request(method: "POST", path: "/manage-members/accept", body: request)
    }

    /// Revoke a pending invitation.
    public func revokeInvitation(_ invitationId: String) async throws -> RevokeInvitationResponse {
        try await http.request(method: "DELETE", path: "/manage-members/invitations/\(invitationId)")
    }

    /// Change a member's role.
    public func changeRole(_ userId: String, _ request: ChangeRoleRequest) async throws -> Member {
        try await http.request(method: "PATCH", path: "/manage-members/\(userId)", body: request)
    }

    /// Remove a member from the organization.
    public func remove(_ userId: String) async throws -> RemoveMemberResponse {
        try await http.request(method: "DELETE", path: "/manage-members/\(userId)")
    }
}
