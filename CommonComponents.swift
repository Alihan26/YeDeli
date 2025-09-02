import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search dishes, cuisines...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Cuisine Filter
struct CuisineFilterView: View {
    @Binding var selectedCuisine: CuisineType
    
    private let cuisines: [CuisineType] = [
        .all, .italian, .indian, .korean, .chinese, .turkish, .middleEastern, .mexican, .thai, .japanese
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(cuisines, id: \.self) { cuisine in
                    CuisineChip(
                        cuisine: cuisine,
                        isSelected: selectedCuisine == cuisine
                    ) {
                        selectedCuisine = cuisine
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CuisineChip: View {
    let cuisine: CuisineType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(cuisine.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Featured Drop Card
struct FeaturedDropCard: View {
    let drop: Drop
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 160, height: 120)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.title)
                        .foregroundColor(.gray)
                )
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(drop.cookName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(drop.dishName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack {
                    Text("CHF \(String(format: "%.2f", drop.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("\(drop.currentOrders)/\(drop.maxOrders)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(drop.pickupTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(drop.pickupDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(width: 160)
    }
}

// MARK: - Recent Order Row
struct RecentOrderRow: View {
    var body: some View {
        HStack(spacing: 12) {
            // Order status icon
            Circle()
                .fill(Color.green)
                .frame(width: 12, height: 12)
            
            // Order details
            VStack(alignment: .leading, spacing: 4) {
                Text("Maria's Lasagna")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Pickup: Today at 18:00")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Order amount
            Text("CHF 12.50")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(8)
    }
}

// MARK: - Empty Orders View
struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Orders Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start exploring and place your first order!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Profile Option Row
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        
        if title != "Settings" {
            Divider()
                .padding(.leading, 56)
        }
    }
}
