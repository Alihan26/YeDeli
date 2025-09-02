import Foundation
import SwiftUI
import CoreLocation

// MARK: - Drop Model
struct Drop: Identifiable, Codable {
    let id: String
    let cookName: String
    let dishName: String
    let cuisine: CuisineType
    let price: Double
    let pickupTime: String
    let pickupDate: String
    let maxOrders: Int
    let currentOrders: Int
    let imageURL: String?
    var coordinate: CLLocationCoordinate2D?
    
    // Custom coding keys to exclude coordinate from Codable
    private enum CodingKeys: String, CodingKey {
        case id, cookName, dishName, cuisine, price, pickupTime, pickupDate, maxOrders, currentOrders, imageURL
    }
    
    var isAvailable: Bool {
        currentOrders < maxOrders
    }
    
    var remainingOrders: Int {
        maxOrders - currentOrders
    }
    
    var orderPercentage: Double {
        Double(currentOrders) / Double(maxOrders)
    }
}

enum CuisineType: String, CaseIterable, Codable {
    case all = "all"
    case italian = "italian"
    case indian = "indian"
    case korean = "korean"
    case chinese = "chinese"
    case turkish = "turkish"
    case middleEastern = "middle_eastern"
    case mexican = "mexican"
    case thai = "thai"
    case japanese = "japanese"
    case swiss = "swiss"
    case mediterranean = "mediterranean"
    case african = "african"
    case caribbean = "caribbean"
    case vietnamese = "vietnamese"
    case spanish = "spanish"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .italian: return "Italian"
        case .indian: return "Indian"
        case .korean: return "Korean"
        case .chinese: return "Chinese"
        case .turkish: return "Turkish"
        case .middleEastern: return "Middle Eastern"
        case .mexican: return "Mexican"
        case .thai: return "Thai"
        case .japanese: return "Japanese"
        case .swiss: return "Swiss"
        case .mediterranean: return "Mediterranean"
        case .african: return "African"
        case .caribbean: return "Caribbean"
        case .vietnamese: return "Vietnamese"
        case .spanish: return "Spanish"
        }
    }
    
    var emoji: String {
        switch self {
        case .all: return "🍽️"
        case .italian: return "🍝"
        case .indian: return "🍛"
        case .korean: return "🍚"
        case .chinese: return "🥟"
        case .turkish: return "🥙"
        case .middleEastern: return "🥙"
        case .mexican: return "🌮"
        case .thai: return "🍜"
        case .japanese: return "🍱"
        case .swiss: return "🧀"
        case .mediterranean: return "🥗"
        case .african: return "🍖"
        case .caribbean: return "🍤"
        case .vietnamese: return "🍜"
        case .spanish: return "🥘"
        }
    }
}

// MARK: - Order Model
struct Order: Identifiable, Codable {
    let id: String
    let dropId: String
    let dropName: String
    let cookName: String
    let status: OrderStatus
    let orderDate: String
    let pickupDate: String
    let pickupTime: String
    let quantity: Int
    let totalPrice: Double
    
    var formattedOrderDate: String {
        formatDate(orderDate)
    }
    
    var formattedPickupDate: String {
        formatDate(pickupDate)
    }
    
    private func formatDate(_ dateString: String) -> String {
        return dateString
    }
}

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case active = "active"
    case ready = "ready"
    case completed = "completed"
    case cancelled = "cancelled"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .active: return "Active"
        case .ready: return "Ready"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .refunded: return "Refunded"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .active: return .green
        case .ready: return .purple
        case .completed: return .green
        case .cancelled: return .red
        case .refunded: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .active: return "play.circle"
        case .ready: return "hand.raised"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        case .refunded: return "arrow.uturn.backward.circle"
        }
    }
}

// MARK: - User Role
enum UserRole: String, CaseIterable, Codable {
    case buyer = "buyer"
    case cook = "cook"
    
    var displayName: String {
        switch self {
        case .buyer: return "Buyer"
        case .cook: return "Cook"
        }
    }
    
    var icon: String {
        switch self {
        case .buyer: return "cart"
        case .cook: return "fork.knife"
        }
    }
}

// MARK: - User Profile
struct UserProfile: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var address: String?
    var profileImage: String?
    var role: UserRole
    var isVerified: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Cook-specific fields
    var cookBio: String?
    var cookSpecialties: [CuisineType]?
    var cookRating: Double?
    var cookTotalOrders: Int?
    var cookIsActive: Bool?
    
    init(id: String = UUID().uuidString, name: String, email: String, phone: String? = nil, address: String? = nil, profileImage: String? = nil, role: UserRole = .buyer, isVerified: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date(), cookBio: String? = nil, cookSpecialties: [CuisineType]? = nil, cookRating: Double? = nil, cookTotalOrders: Int? = nil, cookIsActive: Bool? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.profileImage = profileImage
        self.role = role
        self.isVerified = isVerified
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cookBio = cookBio
        self.cookSpecialties = cookSpecialties
        self.cookRating = cookRating
        self.cookTotalOrders = cookTotalOrders
        self.cookIsActive = cookIsActive
    }
}

struct UserPreferences: Codable {
    var dietaryRestrictions: [DietaryRestriction] = []
    var favoriteCuisines: [CuisineType] = []
    var maxPickupDistance: Double = 5.0
    var notificationsEnabled: Bool = true
    var language: Language = .english
    var currency: Currency = .chf
}

enum DietaryRestriction: String, CaseIterable, Codable {
    case none = "none"
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case glutenFree = "gluten_free"
    case dairyFree = "dairy_free"
    case nutFree = "nut_free"
    case halal = "halal"
    case kosher = "kosher"
    case pescatarian = "pescatarian"
    
    var displayName: String {
        switch self {
        case .none: return "No Restrictions"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten-Free"
        case .dairyFree: return "Dairy-Free"
        case .nutFree: return "Nut-Free"
        case .halal: return "Halal"
        case .kosher: return "Kosher"
        case .pescatarian: return "Pescatarian"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "checkmark.circle"
        case .vegetarian: return "leaf"
        case .vegan: return "leaf.fill"
        case .glutenFree: return "xmark.circle"
        case .dairyFree: return "drop"
        case .nutFree: return "exclamationmark.triangle"
        case .halal: return "star"
        case .kosher: return "star.fill"
        case .pescatarian: return "fish"
        }
    }
}

enum Language: String, CaseIterable, Codable {
    case english = "en"
    case german = "de"
    case french = "fr"
    case italian = "it"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .italian: return "Italiano"
        }
    }
}

enum Currency: String, CaseIterable, Codable {
    case chf = "CHF"
    case eur = "EUR"
    case usd = "USD"
    
    var displayName: String {
        switch self {
        case .chf: return "Swiss Franc (CHF)"
        case .eur: return "Euro (EUR)"
        case .usd: return "US Dollar (USD)"
        }
    }
    
    var symbol: String {
        switch self {
        case .chf: return "CHF"
        case .eur: return "€"
        case .usd: return "$"
        }
    }
}

// MARK: - Dish Model (for Cooks)
struct Dish: Identifiable, Codable {
    let id: String
    let cookId: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String?
    var cuisine: CuisineType
    var dietaryTags: [DietaryRestriction]
    var ingredients: [String]
    var allergens: [String]
    var preparationTime: Int // in minutes
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, cookId: String, name: String, description: String, price: Double, imageURL: String? = nil, cuisine: CuisineType, dietaryTags: [DietaryRestriction] = [], ingredients: [String] = [], allergens: [String] = [], preparationTime: Int = 0, isActive: Bool = true, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.cookId = cookId
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.cuisine = cuisine
        self.dietaryTags = dietaryTags
        self.ingredients = ingredients
        self.allergens = allergens
        self.preparationTime = preparationTime
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Batch Model (for Cooks)
struct Batch: Identifiable, Codable {
    let id: String
    let dishId: String
    let cookId: String
    var scheduledDate: Date
    var pickupDate: Date
    var capacity: Int
    var currentOrders: Int
    var cutoffDate: Date
    var isActive: Bool
    var status: BatchStatus
    var createdAt: Date
    var updatedAt: Date
    
    var availableCapacity: Int {
        return capacity - currentOrders
    }
    
    var isFull: Bool {
        return currentOrders >= capacity
    }
    
    var isCutoffPassed: Bool {
        return Date() > cutoffDate
    }
    
    init(id: String = UUID().uuidString, dishId: String, cookId: String, scheduledDate: Date, pickupDate: Date, capacity: Int, currentOrders: Int = 0, cutoffDate: Date, isActive: Bool = true, status: BatchStatus = .scheduled, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.dishId = dishId
        self.cookId = cookId
        self.scheduledDate = scheduledDate
        self.pickupDate = pickupDate
        self.capacity = capacity
        self.currentOrders = currentOrders
        self.cutoffDate = cutoffDate
        self.isActive = isActive
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Batch Status
enum BatchStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case inProgress = "in_progress"
    case ready = "ready"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .ready: return "Ready"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .inProgress: return "orange"
        case .ready: return "green"
        case .completed: return "gray"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Sample Data
let sampleUser = UserProfile(
    id: "user1",
    name: "John Doe",
    email: "john@example.com",
    phone: "+41 79 123 45 67",
    address: "Zurich, Switzerland",
    profileImage: nil,
    role: .buyer,
    isVerified: true
)

let sampleCook = UserProfile(
    id: "cook1",
    name: "Maria Garcia",
    email: "maria@example.com",
    phone: "+41 79 987 65 43",
    address: "Zurich, Switzerland",
    profileImage: nil,
    role: .cook,
    isVerified: true,
    cookBio: "Passionate home cook specializing in authentic Spanish and Mediterranean cuisine. All dishes made with love and fresh ingredients.",
    cookSpecialties: [.spanish, .mediterranean, .italian],
    cookRating: 4.8,
    cookTotalOrders: 156,
    cookIsActive: true
)

let sampleDish = Dish(
    id: "dish1",
    cookId: "cook1",
    name: "Paella Valenciana",
    description: "Authentic Spanish paella with saffron rice, chicken, seafood, and vegetables. Made with traditional techniques and premium ingredients.",
    price: 28.50,
    imageURL: nil,
    cuisine: .spanish,
    dietaryTags: [.none],
    ingredients: ["Saffron rice", "Chicken", "Shrimp", "Mussels", "Bell peppers", "Peas", "Tomatoes"],
    allergens: ["Shellfish", "Gluten"],
    preparationTime: 45
)

let sampleBatch = Batch(
    id: "batch1",
    dishId: "dish1",
    cookId: "cook1",
    scheduledDate: Date().addingTimeInterval(86400), // Tomorrow
    pickupDate: Date().addingTimeInterval(86400 + 3600), // Tomorrow + 1 hour
    capacity: 20,
    currentOrders: 8,
    cutoffDate: Date().addingTimeInterval(43200), // Tomorrow - 12 hours
    status: .scheduled
)

// Sample data for testing
let sampleDishes = [sampleDish]
let sampleBatches = [sampleBatch]
let sampleUsers = [sampleUser, sampleCook]

// Sample orders for cook dashboard
let sampleOrders: [Order] = [
    Order(
        id: "order1",
        dropId: "drop1",
        dropName: "Paella Valenciana",
        cookName: "Maria's Kitchen",
        status: .confirmed,
        orderDate: "2024-01-14",
        pickupDate: "2024-01-15",
        pickupTime: "12:00 PM",
        quantity: 2,
        totalPrice: 57.00
    ),
    Order(
        id: "order2",
        dropId: "drop1",
        dropName: "Paella Valenciana",
        cookName: "Maria's Kitchen",
        status: .pending,
        orderDate: "2024-01-14",
        pickupDate: "2024-01-15",
        pickupTime: "12:00 PM",
        quantity: 1,
        totalPrice: 28.50
    )
]
