import SwiftUI

struct CookDashboardView: View {
    @State private var selectedTab = 0
    @State private var showingAddDish = false
    @State private var showingAddBatch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cook Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Manage your dishes and orders")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingAddDish = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(title: "Active Orders", value: "12", icon: "cart.fill", color: .blue)
                        StatCard(title: "Today's Batches", value: "3", icon: "clock.fill", color: .orange)
                        StatCard(title: "Total Sales", value: "CHF 456", icon: "dollarsign.circle.fill", color: .green)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    OrdersTabView()
                        .tabItem {
                            Image(systemName: "cart.fill")
                            Text("Orders")
                        }
                        .tag(0)
                    
                    BatchesTabView()
                        .tabItem {
                            Image(systemName: "clock.fill")
                            Text("Batches")
                        }
                        .tag(1)
                    
                    DishesTabView()
                        .tabItem {
                            Image(systemName: "fork.knife")
                            Text("Dishes")
                        }
                        .tag(2)
                    
                    CookProfileTabView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(3)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddDish) {
            AddDishView()
        }
        .sheet(isPresented: $showingAddBatch) {
            AddBatchView()
        }
    }
}

// MARK: - Orders Tab
struct OrdersTabView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sampleOrders) { order in
                    OrderCard(order: order)
                }
            }
            .padding()
        }
    }
}

// MARK: - Batches Tab
struct BatchesTabView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sampleBatches) { batch in
                    BatchCard(batch: batch)
                }
            }
            .padding()
        }
    }
}

// MARK: - Dishes Tab
struct DishesTabView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sampleDishes) { dish in
                    DishCard(dish: dish)
                }
            }
            .padding()
        }
    }
}

// MARK: - Cook Profile Tab
struct CookProfileTabView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text(sampleCook.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(sampleCook.cookBio ?? "")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Stats
                VStack(spacing: 16) {
                    HStack {
                        Text("Cook Statistics")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        StatCard(title: "Rating", value: String(format: "%.1f", sampleCook.cookRating ?? 0.0), icon: "star.fill", color: .yellow)
                        StatCard(title: "Total Orders", value: "\(sampleCook.cookTotalOrders ?? 0)", icon: "bag.fill", color: .blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct OrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.dropName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Order #\(order.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            HStack {
                Label("\(order.quantity)x", systemImage: "number.circle")
                Spacer()
                Text("CHF \(String(format: "%.2f", order.totalPrice))")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            
            HStack {
                Label(order.pickupDate, systemImage: "clock")
                Spacer()
                Text(order.pickupTime)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct BatchCard: View {
    let batch: Batch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Batch #\(batch.id)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(batch.scheduledDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(batch.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForBatchStatus(batch.status).opacity(0.2))
                    .foregroundColor(colorForBatchStatus(batch.status))
                    .cornerRadius(8)
            }
            
            HStack {
                Label("\(batch.currentOrders)/\(batch.capacity)", systemImage: "person.2")
                Spacer()
                Text("CHF 28.50")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            
            HStack {
                Image(systemName: "clock")
                Text(batch.pickupDate, style: .time)
                Spacer()
                Text("Cutoff:")
                Text(batch.cutoffDate, style: .time)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private func colorForBatchStatus(_ status: BatchStatus) -> Color {
    switch status {
    case .scheduled: return .blue
    case .inProgress: return .orange
    case .ready: return .green
    case .completed: return .gray
    case .cancelled: return .red
    }
}

struct DishCard: View {
    let dish: Dish
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dish.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(dish.cuisine.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("CHF \(String(format: "%.2f", dish.price))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Text(dish.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label("\(dish.preparationTime) min", systemImage: "clock")
                Spacer()
                if dish.isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                } else {
                    Text("Inactive")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Placeholder Views (to be implemented)
struct AddDishView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Add New Dish")
                    .font(.title)
                    .padding()
                
                Text("Dish creation form will be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Add Dish")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddBatchView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Add New Batch")
                    .font(.title)
                    .padding()
                
                Text("Batch creation form will be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Add Batch")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CookDashboardView()
}
