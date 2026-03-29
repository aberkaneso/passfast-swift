import Foundation

// MARK: - Enums

public enum PassStatus: String, Codable, Sendable {
    case active
    case invalidated
    case expired
}

public enum WalletType: String, Codable, Sendable {
    case apple
    case google
}

public enum EventType: String, Codable, Sendable {
    case passCreated = "pass.created"
    case passUpdated = "pass.updated"
    case passVoided = "pass.voided"
    case passExpired = "pass.expired"
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
    public let walletType: WalletType?
    public let googleSaveUrl: String?
    public let googleObjectId: String?

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
        case walletType = "wallet_type"
        case googleSaveUrl = "google_save_url"
        case googleObjectId = "google_object_id"
    }
}

public struct WebhookEvent: Codable, Identifiable, Sendable {
    public let id: String
    public let eventType: EventType
    public let payload: [String: AnyCodable]
    public let deliveryStatus: DeliveryStatus
    public let attempts: Int
    public let lastError: String?
    public let deliveredAt: String?
    public let nextRetryAt: String?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case eventType = "event_type"
        case payload
        case deliveryStatus = "delivery_status"
        case attempts
        case lastError = "last_error"
        case deliveredAt = "delivered_at"
        case nextRetryAt = "next_retry_at"
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
        case latitude, longitude, altitude, relevantText
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
    public var walletType: String?

    public init(
        templateId: String,
        serialNumber: String,
        data: [String: AnyCodable],
        externalId: String? = nil,
        expiresAt: String? = nil,
        getOrCreate: Bool? = nil,
        locations: [PassLocation]? = nil,
        relevantDate: String? = nil,
        maxDistance: Double? = nil,
        walletType: String? = nil
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
        self.walletType = walletType
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
        case walletType = "wallet_type"
    }
}

public struct UpdatePassRequest: Encodable, Sendable {
    public var data: [String: AnyCodable]?
    public var pushUpdate: Bool?
    public var expiresAt: String?
    public var locations: [PassLocation]?
    public var relevantDate: String?
    public var maxDistance: Double?

    public init(
        data: [String: AnyCodable]? = nil,
        pushUpdate: Bool? = nil,
        expiresAt: String? = nil,
        locations: [PassLocation]? = nil,
        relevantDate: String? = nil,
        maxDistance: Double? = nil
    ) {
        self.data = data
        self.pushUpdate = pushUpdate
        self.expiresAt = expiresAt
        self.locations = locations
        self.relevantDate = relevantDate
        self.maxDistance = maxDistance
    }

    enum CodingKeys: String, CodingKey {
        case data
        case pushUpdate = "push_update"
        case expiresAt = "expires_at"
        case locations
        case relevantDate = "relevant_date"
        case maxDistance = "max_distance"
    }
}

// MARK: - Response Types

public struct GeneratePassResponse: Sendable {
    public let passId: String
    public let pkpassData: Data
    public let existed: Bool
}

public struct GoogleGenerateResponse: Codable, Sendable {
    public let id: String
    public let serialNumber: String
    public let walletType: String
    public let saveUrl: String
    public let googleObjectId: String
    public let status: String
    public let externalId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case walletType = "wallet_type"
        case saveUrl = "save_url"
        case googleObjectId = "google_object_id"
        case status
        case externalId = "external_id"
    }
}

public struct DualAppleResult: Codable, Sendable {
    public let id: String
    public let serialNumber: String
    public let walletType: String
    public let status: String
    public let downloadUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case walletType = "wallet_type"
        case status
        case downloadUrl = "download_url"
    }
}

public struct DualGoogleResult: Codable, Sendable {
    public let id: String
    public let serialNumber: String
    public let walletType: String
    public let status: String
    public let saveUrl: String
    public let googleObjectId: String

    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case walletType = "wallet_type"
        case status
        case saveUrl = "save_url"
        case googleObjectId = "google_object_id"
    }
}

public struct DualGenerateResponse: Codable, Sendable {
    public let apple: DualAppleResult?
    public let google: DualGoogleResult?
    public let warnings: [String]?
}

public struct UpdatePassResponse: Codable, Sendable {
    public let id: String
    public let status: PassStatus
    public let devicesNotified: Int
    public let updatedAt: String
    public let expiresAt: String?
    public let walletType: String?

    enum CodingKeys: String, CodingKey {
        case id, status
        case devicesNotified = "devices_notified"
        case updatedAt = "updated_at"
        case expiresAt = "expires_at"
        case walletType = "wallet_type"
    }
}

public struct VoidPassResponse: Codable, Sendable {
    public let id: String
    public let serialNumber: String
    public let status: PassStatus
    public let voidedAt: String
    public let updatedAt: String
    public let pkpassRebuilt: Bool
    public let devicesNotified: Int
    public let warning: String?

    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber = "serial_number"
        case status
        case voidedAt = "voided_at"
        case updatedAt = "updated_at"
        case pkpassRebuilt = "pkpass_rebuilt"
        case devicesNotified = "devices_notified"
        case warning
    }
}

// MARK: - Query Parameters

public struct ListPassesParams: Sendable {
    public var status: PassStatus?
    public var serialNumber: String?
    public var externalId: String?
    public var templateId: String?
    public var limit: Int?
    public var offset: Int?
    public var createdAfter: String?
    public var createdBefore: String?
    public var walletType: String?

    public init(
        status: PassStatus? = nil,
        serialNumber: String? = nil,
        externalId: String? = nil,
        templateId: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        createdAfter: String? = nil,
        createdBefore: String? = nil,
        walletType: String? = nil
    ) {
        self.status = status
        self.serialNumber = serialNumber
        self.externalId = externalId
        self.templateId = templateId
        self.limit = limit
        self.offset = offset
        self.createdAfter = createdAfter
        self.createdBefore = createdBefore
        self.walletType = walletType
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
        if let walletType { items.append(.init(name: "wallet_type", value: walletType)) }
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
