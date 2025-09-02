import SwiftUI

struct OrdersView: View {
    @State private var selectedTab = 0
    @State private var orders: [Order] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Order Status", selection: $selectedTab) {
                    Text("Active").tag(0)
                    Text("Completed").tag(1)
                    Text("Cancelled").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Orders list
                if orders.isEmpty {
                    EmptyOrdersView()
                } else {
                    List(orders) { order in
                        OrderRow(order: order)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadOrders()
        }
    }
    
    private func loadOrders() {
        // TODO: Load from API
        orders = [
            Order(id: "1", dropId: "1", dropName: "Maria's Lasagna", cookName: "Maria's Kitchen", status: .active, orderDate: "2024-01-15", pickupDate: "2024-01-15", pickupTime: "18:00", quantity: 1, totalPrice: 12.50),
            Order(id: "2", dropId: "2", dropName: "Ahmed's Biryani", cookName: "Ahmed's Delights", status: .completed, orderDate: "2024-01-14", pickupDate: "2024-01-14", pickupTime: "19:00", quantity: 2, totalPrice: 30.00),
            Order(id: "3", dropId: "3", dropName: "Kim's Kimbap", cookName: "Kim's Korean", status: .cancelled, orderDate: "2024-01-13", pickupDate: "2024-01-13", pickupTime: "17:30", quantity: 1, totalPrice: 8.50)
        ]
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.dropName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(order.cookName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pickup: \(order.pickupDate) at \(order.pickupTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Qty: \(order.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("CHF \(String(format: "%.2f", order.totalPrice))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            if order.status == .active {
                HStack {
                    Button("View Details") {
                        // Navigate to order details
                    }
                    .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button("Cancel Order") {
                        // Cancel order action
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    OrdersView()
}
