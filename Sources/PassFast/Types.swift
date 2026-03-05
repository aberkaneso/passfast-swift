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
    case invalidated
    case expired
}

public enum TemplateStatus: String, Codable, Sendable {
    case draft
    case published
    case archived
}

public enum InvitationStatus: String, Codable, Sendable {
    case pending
    case accepted
    case expired
    case revoked
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
    public let voidedAt: String?
    public let createdAt: String
    public let updatedAt: String
    public let lastUpdatedAt: String?

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
        case voidedAt = "voided_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastUpdatedAt = "last_updated_at"
    }
}

public struct Template: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let appId: String
    public let name: String
    public let description: String?
    public let passStyle: PassStyle
    public let structure: [String: AnyCodable]
    public let fieldSchema: [String: AnyCodable]?
    public let status: TemplateStatus
    public let iconImageId: String?
    public let logoImageId: String?
    public let stripImageId: String?
    public let thumbnailImageId: String?
    public let backgroundImageId: String?
    public let publishedAt: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case appId = "app_id"
        case name, description
        case passStyle = "pass_style"
        case structure
        case fieldSchema = "field_schema"
        case status
        case iconImageId = "icon_image_id"
        case logoImageId = "logo_image_id"
        case stripImageId = "strip_image_id"
        case thumbnailImageId = "thumbnail_image_id"
        case backgroundImageId = "background_image_id"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct PassImage: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let appId: String
    public let purpose: String
    public let filename: String
    public let storagePath: String
    public let previewUrl: String?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case appId = "app_id"
        case purpose
        case filename
        case storagePath = "storage_path"
        case previewUrl = "preview_url"
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
    public let updatedAt: String?

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
        case updatedAt = "updated_at"
    }
}

public struct Organization: Codable, Identifiable, Sendable, CustomStringConvertible {
    public let id: String
    public let name: String
    public let slug: String?
    public let apnsKeyId: String?
    public let billingPlan: String?
    public let monthlyPassLimit: Int?
    public let features: [String: AnyCodable]?
    public let isActive: Bool?
    public let webhookSecret: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case apnsKeyId = "apns_key_id"
        case billingPlan = "billing_plan"
        case monthlyPassLimit = "monthly_pass_limit"
        case features
        case isActive = "is_active"
        case webhookSecret = "webhook_secret"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public var description: String {
        "Organization(id: \(id), name: \(name), webhookSecret: [REDACTED])"
    }
}

public struct App: Codable, Identifiable, Sendable, CustomStringConvertible {
    public let id: String
    public let organizationId: String
    public let name: String
    public let appleTeamId: String?
    public let passTypeIdentifier: String?
    public let validationWebhookUrl: String?
    public let webhookUrl: String?
    public let isActive: Bool?
    public let webhookSecret: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
        case validationWebhookUrl = "validation_webhook_url"
        case webhookUrl = "webhook_url"
        case isActive = "is_active"
        case webhookSecret = "webhook_secret"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public var description: String {
        "App(id: \(id), name: \(name), webhookSecret: [REDACTED])"
    }
}

public struct ApiKey: Codable, Identifiable, Sendable {
    public let id: String
    public let organizationId: String
    public let name: String
    public let keyType: KeyType
    public let keyPrefix: String
    public let scopes: [String]
    public let expiresAt: String?
    public let isActive: Bool?
    public let lastUsedAt: String?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case keyType = "key_type"
        case keyPrefix = "key_prefix"
        case scopes
        case expiresAt = "expires_at"
        case isActive = "is_active"
        case lastUsedAt = "last_used_at"
        case createdAt = "created_at"
    }
}

public struct ApiKeyCreated: Codable, Sendable, CustomStringConvertible {
    public let id: String
    public let organizationId: String
    public let name: String
    public let keyType: KeyType
    public let keyPrefix: String
    public let scopes: [String]
    public let rawKey: String
    public let expiresAt: String?
    public let isActive: Bool?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case keyType = "key_type"
        case keyPrefix = "key_prefix"
        case scopes
        case rawKey = "raw_key"
        case expiresAt = "expires_at"
        case isActive = "is_active"
        case createdAt = "created_at"
    }

    public var description: String {
        "ApiKeyCreated(id: \(id), name: \(name), keyPrefix: \(keyPrefix), rawKey: [REDACTED])"
    }
}

public struct Member: Codable, Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let email: String
    public let role: OrgRole
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case email, role
        case createdAt = "created_at"
    }
}

public struct Invitation: Codable, Identifiable, Sendable {
    public let id: String
    public let email: String
    public let role: OrgRole
    public let status: InvitationStatus
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

public struct PassLocation: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public var altitude: Double?
    public var relevantText: String?

    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        relevantText: String? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.relevantText = relevantText
    }

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, altitude
        case relevantText = "relevant_text"
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
    public var locations: [PassLocation]?
    public var relevantDate: String?
    public var maxDistance: Double?

    public init(
        templateId: String,
        serialNumber: String,
        data: [String: AnyCodable],
        externalId: String? = nil,
        expiresAt: String? = nil,
        getOrCreate: Bool? = nil,
        locations: [PassLocation]? = nil,
        relevantDate: String? = nil,
        maxDistance: Double? = nil
    ) {
        self.templateId = templateId
        self.serialNumber = serialNumber
        self.data = data
        self.externalId = externalId
        self.expiresAt = expiresAt
        self.getOrCreate = getOrCreate
        self.locations = locations
        self.relevantDate = relevantDate
        self.maxDistance = maxDistance
    }

    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
        case serialNumber = "serial_number"
        case data
        case externalId = "external_id"
        case expiresAt = "expires_at"
        case getOrCreate = "get_or_create"
        case locations
        case relevantDate = "relevant_date"
        case maxDistance = "max_distance"
    }
}

public struct UpdatePassRequest: Encodable, Sendable {
    public var data: [String: AnyCodable]?
    public var pushUpdate: Bool?
    public var locations: [PassLocation]?
    public var relevantDate: String?
    public var maxDistance: Double?

    public init(
        data: [String: AnyCodable]? = nil,
        pushUpdate: Bool? = nil,
        locations: [PassLocation]? = nil,
        relevantDate: String? = nil,
        maxDistance: Double? = nil
    ) {
        self.data = data
        self.pushUpdate = pushUpdate
        self.locations = locations
        self.relevantDate = relevantDate
        self.maxDistance = maxDistance
    }

    enum CodingKeys: String, CodingKey {
        case data
        case pushUpdate = "push_update"
        case locations
        case relevantDate = "relevant_date"
        case maxDistance = "max_distance"
    }
}

public struct CreateTemplateRequest: Encodable, Sendable {
    public let name: String
    public let passStyle: PassStyle
    public let structure: [String: AnyCodable]
    public var description: String?
    public var fieldSchema: [String: AnyCodable]?
    public var iconImageId: String?
    public var logoImageId: String?
    public var stripImageId: String?
    public var thumbnailImageId: String?
    public var backgroundImageId: String?

    public init(
        name: String,
        passStyle: PassStyle,
        structure: [String: AnyCodable],
        description: String? = nil,
        fieldSchema: [String: AnyCodable]? = nil,
        iconImageId: String? = nil,
        logoImageId: String? = nil,
        stripImageId: String? = nil,
        thumbnailImageId: String? = nil,
        backgroundImageId: String? = nil
    ) {
        self.name = name
        self.passStyle = passStyle
        self.structure = structure
        self.description = description
        self.fieldSchema = fieldSchema
        self.iconImageId = iconImageId
        self.logoImageId = logoImageId
        self.stripImageId = stripImageId
        self.thumbnailImageId = thumbnailImageId
        self.backgroundImageId = backgroundImageId
    }

    enum CodingKeys: String, CodingKey {
        case name, description
        case passStyle = "pass_style"
        case structure
        case fieldSchema = "field_schema"
        case iconImageId = "icon_image_id"
        case logoImageId = "logo_image_id"
        case stripImageId = "strip_image_id"
        case thumbnailImageId = "thumbnail_image_id"
        case backgroundImageId = "background_image_id"
    }
}

public struct UpdateTemplateRequest: Encodable, Sendable {
    public var name: String?
    public var description: String?
    public var passStyle: PassStyle?
    public var structure: [String: AnyCodable]?
    public var fieldSchema: [String: AnyCodable]?

    public init(
        name: String? = nil,
        description: String? = nil,
        passStyle: PassStyle? = nil,
        structure: [String: AnyCodable]? = nil,
        fieldSchema: [String: AnyCodable]? = nil
    ) {
        self.name = name
        self.description = description
        self.passStyle = passStyle
        self.structure = structure
        self.fieldSchema = fieldSchema
    }

    enum CodingKeys: String, CodingKey {
        case name, description
        case passStyle = "pass_style"
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
    public var name: String?

    public init(name: String? = nil) {
        self.name = name
    }
}

public struct UpdateAppRequest: Encodable, Sendable {
    public var name: String?
    public var appleTeamId: String?
    public var passTypeIdentifier: String?
    public var validationWebhookUrl: String?
    public var webhookUrl: String?
    public var regenerateWebhookSecret: Bool?

    public init(
        name: String? = nil,
        appleTeamId: String? = nil,
        passTypeIdentifier: String? = nil,
        validationWebhookUrl: String? = nil,
        webhookUrl: String? = nil,
        regenerateWebhookSecret: Bool? = nil
    ) {
        self.name = name
        self.appleTeamId = appleTeamId
        self.passTypeIdentifier = passTypeIdentifier
        self.validationWebhookUrl = validationWebhookUrl
        self.webhookUrl = webhookUrl
        self.regenerateWebhookSecret = regenerateWebhookSecret
    }

    enum CodingKeys: String, CodingKey {
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
        case validationWebhookUrl = "validation_webhook_url"
        case webhookUrl = "webhook_url"
        case regenerateWebhookSecret = "regenerate_webhook_secret"
    }
}

public struct UpdateOrgRequest: Encodable, Sendable {
    public var name: String?
    public var slug: String?
    public var apnsKeyId: String?
    public var apnsKeyP8: String?

    public init(
        name: String? = nil,
        slug: String? = nil,
        apnsKeyId: String? = nil,
        apnsKeyP8: String? = nil
    ) {
        self.name = name
        self.slug = slug
        self.apnsKeyId = apnsKeyId
        self.apnsKeyP8 = apnsKeyP8
    }

    enum CodingKeys: String, CodingKey {
        case name, slug
        case apnsKeyId = "apns_key_id"
        case apnsKeyP8 = "apns_key_p8"
    }
}

public struct UploadImageRequest: Encodable, Sendable {
    public let purpose: String
    public let filename: String
    public let data: String

    public init(purpose: String, filename: String, data: String) {
        self.purpose = purpose
        self.filename = filename
        self.data = data
    }
}

public struct UploadCertificateRequest: Encodable, Sendable {
    public let certType: CertType
    public let certData: String

    public init(certType: CertType, certData: String) {
        self.certType = certType
        self.certData = certData
    }

    enum CodingKeys: String, CodingKey {
        case certType = "cert_type"
        case certData = "cert_data"
    }
}

public struct UploadP12Request: Encodable, Sendable, CustomStringConvertible {
    public let p12Data: String
    public var password: String?

    public init(p12Data: String, password: String? = nil) {
        self.p12Data = p12Data
        self.password = password
    }

    enum CodingKeys: String, CodingKey {
        case p12Data = "p12_data"
        case password
    }

    public var description: String {
        "UploadP12Request(p12Data: [\(p12Data.count) chars], password: [REDACTED])"
    }
}

public struct AcceptInvitationRequest: Encodable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

// MARK: - Response Types

public struct GeneratePassResponse: Sendable {
    public let passId: String
    public let pkpassData: Data
    public let existed: Bool
}

public struct UpdatePassResponse: Codable, Sendable {
    public let id: String
    public let status: PassStatus
    public let devicesNotified: Int
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, status
        case devicesNotified = "devices_notified"
        case updatedAt = "updated_at"
    }
}

public struct VoidPassResponse: Codable, Sendable {
    public let id: String
    public let serialNumber: String
    public let status: PassStatus
    public let voidedAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case status
        case voidedAt = "voided_at"
        case updatedAt = "updated_at"
    }
}

public struct UpdateAppResponse: Codable, Sendable, CustomStringConvertible {
    public let id: String
    public let organizationId: String
    public let name: String
    public let appleTeamId: String?
    public let passTypeIdentifier: String?
    public let validationWebhookUrl: String?
    public let webhookUrl: String?
    public let webhookSecretRaw: String?
    public let isActive: Bool?
    public let webhookSecret: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case name
        case appleTeamId = "apple_team_id"
        case passTypeIdentifier = "pass_type_identifier"
        case validationWebhookUrl = "validation_webhook_url"
        case webhookUrl = "webhook_url"
        case webhookSecretRaw = "webhook_secret_raw"
        case isActive = "is_active"
        case webhookSecret = "webhook_secret"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public var description: String {
        "UpdateAppResponse(id: \(id), name: \(name), webhookSecretRaw: [REDACTED], webhookSecret: [REDACTED])"
    }
}

public struct RevokeApiKeyResponse: Codable, Sendable {
    public let id: String
    public let isActive: Bool
    public let message: String

    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case message
    }
}

public struct DeleteApiKeyResponse: Codable, Sendable {
    public let id: String
    public let message: String
}

public struct AcceptInvitationResponse: Codable, Sendable {
    public let organizationId: String
    public let userId: String
    public let role: OrgRole

    enum CodingKeys: String, CodingKey {
        case organizationId = "organization_id"
        case userId = "user_id"
        case role
    }
}

public struct RemoveMemberResponse: Codable, Sendable {
    public let id: String
    public let removed: Bool
}

public struct RevokeInvitationResponse: Codable, Sendable {
    public let id: String
    public let status: InvitationStatus
}

public struct UploadP12Response: Codable, Sendable {
    public let message: String
    public let certificates: [Certificate]
}

public struct TestWebhookResponse: Codable, Sendable {
    public let webhookUrl: String
    public let success: Bool
    public let approved: Bool
    public let reason: String?
    public let statusCode: Int?
    public let durationMs: Int?

    enum CodingKeys: String, CodingKey {
        case webhookUrl = "webhook_url"
        case success, approved, reason
        case statusCode = "status_code"
        case durationMs = "duration_ms"
    }
}

public struct ListPassesParams: Sendable {
    public var status: PassStatus?
    public var serialNumber: String?
    public var externalId: String?
    public var templateId: String?
    public var limit: Int?
    public var offset: Int?
    public var createdAfter: String?
    public var createdBefore: String?

    public init(
        status: PassStatus? = nil,
        serialNumber: String? = nil,
        externalId: String? = nil,
        templateId: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        createdAfter: String? = nil,
        createdBefore: String? = nil
    ) {
        self.status = status
        self.serialNumber = serialNumber
        self.externalId = externalId
        self.templateId = templateId
        self.limit = limit
        self.offset = offset
        self.createdAfter = createdAfter
        self.createdBefore = createdBefore
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let status { items.append(.init(name: "status", value: status.rawValue)) }
        if let serialNumber { items.append(.init(name: "serial_number", value: serialNumber)) }
        if let externalId { items.append(.init(name: "external_id", value: externalId)) }
        if let templateId { items.append(.init(name: "template_id", value: templateId)) }
        if let limit { items.append(.init(name: "limit", value: String(limit))) }
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        if let createdAfter { items.append(.init(name: "created_after", value: createdAfter)) }
        if let createdBefore { items.append(.init(name: "created_before", value: createdBefore)) }
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
