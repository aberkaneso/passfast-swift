import Foundation

// MARK: - Enums

public enum PassStyle: String, Codable, Sendable {
    case coupon
    case eventTicket
    case generic
    case boardingPass
    case storeCard
}

public enum PassStatus: String, Codable, Sendable {
    case active
    case voided
    case expired
}

public enum CertType: String, Codable, Sendable {
    case signerCert = "signer_cert"
    case signerKey = "signer_key"
    case wwdr
}

public enum KeyType: String, Codable, Sendable {
    case secret
    case publishable
}

public enum OrgRole: String, Codable, Sendable {
    case owner
    case admin
    case editor
    case viewer
}

public enum EventType: String, Codable, Sendable {
    case passCreated = "pass.created"
    case passUpdated = "pass.updated"
    case passVoided = "pass.voided"
    case deviceRegistered = "device.registered"
    case deviceUnregistered = "device.unregistered"
}

public enum DeliveryStatus: String, Codable, Sendable {
    case pending
    case delivered
    case failed
}

// MARK: - Models

public struct Pass: Codable, Identifiable, Sendable {
    public let id: String
    public let serialNumber: String
    public let templateId: String
    public let organizationId: String
    public let appId: String
    public let status: PassStatus
    public let dynamicData: [String: AnyCodable]
    public let externalId: String?
    public let authenticationToken: String
    public let pkpassStoragePath: String
    public let pkpassHash: String
    public let expiresAt: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case templateId = "template_id"
        case organizationId = "organization_id"
        case appId = "app_id"
        case status
        case dynamicData = "dynamic_data"
        case externalId = "external_id"
        case authenticationToken = "authentication_token"
        case pkpassStoragePath = "pkpass_storage_path"
        case pkpassHash = "pkpass_hash"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct Template: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let appId: String
    public let name: String
    public let passStyle: PassStyle
    public let structure: [String: AnyCodable]
    public let fieldSchema: [String: AnyCodable]?
    public let isPublished: Bool
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case appId = "app_id"
        case name
        case passStyle = "pass_style"
        case structure
        case fieldSchema = "field_schema"
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct PassImage: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let appId: String
    public let imageType: String
    public let filename: String
    public let storagePath: String
    public let contentType: String
    public let size: Int
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case appId = "app_id"
        case imageType = "image_type"
        case filename
        case storagePath = "storage_path"
        case contentType = "content_type"
        case size
        case createdAt = "created_at"
    }
}

public struct Certificate: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let appId: String
    public let certType: CertType
    public let filename: String
    public let subject: String?
    public let issuer: String?
    public let validFrom: String?
    public let validTo: String?
    public let isActive: Bool
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case appId = "app_id"
        case certType = "cert_type"
        case filename
        case subject, issuer
        case validFrom = "valid_from"
        case validTo = "valid_to"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

public struct Organization: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct App: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let name: String
    public let appleTeamId: String?
    public let passTypeIdentifier: String?
    public let validationWebhookUrl: String?
    public let eventWebhookUrl: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
        case validationWebhookUrl = "validation_webhook_url"
        case eventWebhookUrl = "event_webhook_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct ApiKey: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let name: String
    public let keyType: KeyType
    public let prefix: String
    public let scopes: [String]
    public let lastUsedAt: String?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case keyType = "key_type"
        case prefix
        case scopes
        case lastUsedAt = "last_used_at"
        case createdAt = "created_at"
    }
}

public struct ApiKeyCreated: Codable, Sendable {
    public let id: String
    public let organizationId: String
    public let name: String
    public let keyType: KeyType
    public let prefix: String
    public let scopes: [String]
    public let rawKey: String
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case keyType = "key_type"
        case prefix
        case scopes
        case rawKey = "raw_key"
        case createdAt = "created_at"
    }
}

public struct Member: Codable, Sendable {
    public let userId: String
    public let email: String
    public let role: OrgRole
    public let joinedAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email, role
        case joinedAt = "joined_at"
    }
}

public struct Invitation: Codable, Identifiable, Sendable {
    public let id: String
    public let email: String
    public let role: OrgRole
    public let status: String
    public let expiresAt: String
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, email, role, status
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}

public struct WebhookEvent: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let appId: String
    public let eventType: EventType
    public let payload: [String: AnyCodable]
    public let deliveryStatus: DeliveryStatus
    public let attempts: Int
    public let lastAttemptAt: String?
    public let deliveredAt: String?
    public let nextRetryAt: String?
    public let lastError: String?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case appId = "app_id"
        case eventType = "event_type"
        case payload
        case deliveryStatus = "delivery_status"
        case attempts
        case lastAttemptAt = "last_attempt_at"
        case deliveredAt = "delivered_at"
        case nextRetryAt = "next_retry_at"
        case lastError = "last_error"
        case createdAt = "created_at"
    }
}

// MARK: - Request Types

public struct GeneratePassRequest: Encodable, Sendable {
    public let templateId: String
    public let serialNumber: String
    public let data: [String: AnyCodable]
    public var externalId: String?
    public var expiresAt: String?
    public var getOrCreate: Bool?

    public init(
        templateId: String,
        serialNumber: String,
        data: [String: AnyCodable],
        externalId: String? = nil,
        expiresAt: String? = nil,
        getOrCreate: Bool? = nil
    ) {
        self.templateId = templateId
        self.serialNumber = serialNumber
        self.data = data
        self.externalId = externalId
        self.expiresAt = expiresAt
        self.getOrCreate = getOrCreate
    }

    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
        case serialNumber = "serial_number"
        case data
        case externalId = "external_id"
        case expiresAt = "expires_at"
        case getOrCreate = "get_or_create"
    }
}

public struct UpdatePassRequest: Encodable, Sendable {
    public var data: [String: AnyCodable]?
    public var expiresAt: String?

    public init(data: [String: AnyCodable]? = nil, expiresAt: String? = nil) {
        self.data = data
        self.expiresAt = expiresAt
    }

    enum CodingKeys: String, CodingKey {
        case data
        case expiresAt = "expires_at"
    }
}

public struct CreateTemplateRequest: Encodable, Sendable {
    public let name: String
    public let passStyle: PassStyle
    public let structure: [String: AnyCodable]
    public var fieldSchema: [String: AnyCodable]?

    public init(
        name: String,
        passStyle: PassStyle,
        structure: [String: AnyCodable],
        fieldSchema: [String: AnyCodable]? = nil
    ) {
        self.name = name
        self.passStyle = passStyle
        self.structure = structure
        self.fieldSchema = fieldSchema
    }

    enum CodingKeys: String, CodingKey {
        case name
        case passStyle = "pass_style"
        case structure
        case fieldSchema = "field_schema"
    }
}

public struct UpdateTemplateRequest: Encodable, Sendable {
    public var name: String?
    public var structure: [String: AnyCodable]?
    public var fieldSchema: [String: AnyCodable]?

    public init(
        name: String? = nil,
        structure: [String: AnyCodable]? = nil,
        fieldSchema: [String: AnyCodable]? = nil
    ) {
        self.name = name
        self.structure = structure
        self.fieldSchema = fieldSchema
    }

    enum CodingKeys: String, CodingKey {
        case name
        case structure
        case fieldSchema = "field_schema"
    }
}

public struct CreateApiKeyRequest: Encodable, Sendable {
    public let name: String
    public let keyType: KeyType
    public var scopes: [String]?

    public init(name: String, keyType: KeyType, scopes: [String]? = nil) {
        self.name = name
        self.keyType = keyType
        self.scopes = scopes
    }

    enum CodingKeys: String, CodingKey {
        case name
        case keyType = "key_type"
        case scopes
    }
}

public struct InviteMemberRequest: Encodable, Sendable {
    public let email: String
    public let role: OrgRole

    public init(email: String, role: OrgRole) {
        self.email = email
        self.role = role
    }
}

public struct ChangeRoleRequest: Encodable, Sendable {
    public let role: OrgRole

    public init(role: OrgRole) {
        self.role = role
    }
}

public struct CreateAppRequest: Encodable, Sendable {
    public let name: String
    public var appleTeamId: String?
    public var passTypeIdentifier: String?

    public init(name: String, appleTeamId: String? = nil, passTypeIdentifier: String? = nil) {
        self.name = name
        self.appleTeamId = appleTeamId
        self.passTypeIdentifier = passTypeIdentifier
    }

    enum CodingKeys: String, CodingKey {
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
    }
}

public struct UpdateAppRequest: Encodable, Sendable {
    public var name: String?
    public var appleTeamId: String?
    public var passTypeIdentifier: String?
    public var validationWebhookUrl: String?
    public var eventWebhookUrl: String?
    public var regenerateWebhookSecret: Bool?

    public init(
        name: String? = nil,
        appleTeamId: String? = nil,
        passTypeIdentifier: String? = nil,
        validationWebhookUrl: String? = nil,
        eventWebhookUrl: String? = nil,
        regenerateWebhookSecret: Bool? = nil
    ) {
        self.name = name
        self.appleTeamId = appleTeamId
        self.passTypeIdentifier = passTypeIdentifier
        self.validationWebhookUrl = validationWebhookUrl
        self.eventWebhookUrl = eventWebhookUrl
        self.regenerateWebhookSecret = regenerateWebhookSecret
    }

    enum CodingKeys: String, CodingKey {
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
        case validationWebhookUrl = "validation_webhook_url"
        case eventWebhookUrl = "event_webhook_url"
        case regenerateWebhookSecret = "regenerate_webhook_secret"
    }
}

public struct UpdateOrgRequest: Encodable, Sendable {
    public var name: String?

    public init(name: String? = nil) {
        self.name = name
    }
}

// MARK: - Response Types

public struct GeneratePassResponse: Sendable {
    public let passId: String
    public let pkpassData: Data
    public let existed: Bool
}

public struct UpdatePassResponse: Codable, Sendable {
    public let pass: Pass
    public let pushSent: Bool

    enum CodingKeys: String, CodingKey {
        case pass
        case pushSent = "push_sent"
    }
}

public struct VoidPassResponse: Codable, Sendable {
    public let pass: Pass
    public let pushSent: Bool

    enum CodingKeys: String, CodingKey {
        case pass
        case pushSent = "push_sent"
    }
}

public struct UpdateAppResponse: Codable, Sendable {
    public let id: String
    public let organizationId: String
    public let name: String
    public let appleTeamId: String?
    public let passTypeIdentifier: String?
    public let validationWebhookUrl: String?
    public let eventWebhookUrl: String?
    public let webhookSecretRaw: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
        case validationWebhookUrl = "validation_webhook_url"
        case eventWebhookUrl = "event_webhook_url"
        case webhookSecretRaw = "webhook_secret_raw"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct MemberListResponse: Codable, Sendable {
    public let members: [Member]
    public let invitations: [Invitation]
}

public struct TestWebhookResponse: Codable, Sendable {
    public let success: Bool
    public let status: Int?
    public let body: AnyCodable?
}

public struct ListPassesParams: Sendable {
    public var status: PassStatus?
    public var serialNumber: String?
    public var externalId: String?
    public var templateId: String?
    public var limit: Int?
    public var offset: Int?

    public init(
        status: PassStatus? = nil,
        serialNumber: String? = nil,
        externalId: String? = nil,
        templateId: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.status = status
        self.serialNumber = serialNumber
        self.externalId = externalId
        self.templateId = templateId
        self.limit = limit
        self.offset = offset
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let status { items.append(.init(name: "status", value: status.rawValue)) }
        if let serialNumber { items.append(.init(name: "serial_number", value: serialNumber)) }
        if let externalId { items.append(.init(name: "external_id", value: externalId)) }
        if let templateId { items.append(.init(name: "template_id", value: templateId)) }
        if let limit { items.append(.init(name: "limit", value: String(limit))) }
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        return items
    }
}

public struct ListWebhookEventsParams: Sendable {
    public var eventType: EventType?
    public var deliveryStatus: DeliveryStatus?
    public var limit: Int?
    public var offset: Int?

    public init(
        eventType: EventType? = nil,
        deliveryStatus: DeliveryStatus? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.eventType = eventType
        self.deliveryStatus = deliveryStatus
        self.limit = limit
        self.offset = offset
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let eventType { items.append(.init(name: "event_type", value: eventType.rawValue)) }
        if let deliveryStatus { items.append(.init(name: "delivery_status", value: deliveryStatus.rawValue)) }
        if let limit { items.append(.init(name: "limit", value: String(limit))) }
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        return items
    }
}
