import Foundation

/// Manages organization members — list, invite, change role, remove.
public struct MemberResource: Sendable {
    let http: HTTPClient

    /// List all organization members and pending invitations.
    public func list() async throws -> MemberListResponse {
        try await http.request(method: "GET", path: "/manage-members")
    }

    /// Invite a new member by email.
    public func invite(_ request: InviteMemberRequest) async throws -> Invitation {
        try await http.request(method: "POST", path: "/manage-members/invite", body: request)
    }

    /// Change a member's role.
    public func changeRole(_ userId: String, _ request: ChangeRoleRequest) async throws -> Member {
        try await http.request(method: "PATCH", path: "/manage-members/\(userId)/role", body: request)
    }

    /// Remove a member from the organization.
    public func remove(_ userId: String) async throws {
        try await http.request(method: "DELETE", path: "/manage-members/\(userId)") as Void
    }
}
