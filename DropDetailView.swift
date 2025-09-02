import SwiftUI

struct DropDetailView: View {
    let drop: Drop
    @Environment(\.dismiss) private var dismiss
    @State private var quantity = 1
    @State private var showingOrderConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image section
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Basic info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(drop.dishName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(drop.cookName)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(drop.cuisine.displayName)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(16)
                                
                                Spacer()
                                
                                Text("CHF \(String(format: "%.2f", drop.price))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Divider()
                        
                        // Pickup details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pickup Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.orange)
                                Text("Date: \(drop.pickupDate)")
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.orange)
                                Text("Time: \(drop.pickupTime)")
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.orange)
                                Text("Location: Zurich, Switzerland")
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        // Availability
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Availability")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text("Orders: \(drop.currentOrders)/\(drop.maxOrders)")
                                Spacer()
                                
                                if drop.isAvailable {
                                    Text("Available")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                } else {
                                    Text("Sold Out")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                            }
                            
                            ProgressView(value: drop.orderPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        }
                        
                        Divider()
                        
                        // Order section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Order")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text("Quantity:")
                                Spacer()
                                
                                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.orange)
                                }
                                
                                Text("\(quantity)")
                                    .font(.headline)
                                    .frame(minWidth: 40)
                                
                                Button(action: { if quantity < drop.remainingOrders { quantity += 1 } }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            HStack {
                                Text("Total:")
                                Spacer()
                                Text("CHF \(String(format: "%.2f", drop.price * Double(quantity)))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Drop Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        showingOrderConfirmation = true
                    }) {
                        Text("Place Order")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(drop.isAvailable ? Color.orange : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!drop.isAvailable)
                    .padding()
                }
                .background(Color(.systemBackground))
            }
        }
        .alert("Confirm Order", isPresented: $showingOrderConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                // TODO: Process order
                dismiss()
            }
        } message: {
            Text("Are you sure you want to order \(quantity) \(quantity == 1 ? "portion" : "portions") of \(drop.dishName) for CHF \(String(format: "%.2f", drop.price * Double(quantity)))?")
        }
    }
}

#Preview {
    DropDetailView(drop: Drop(
        id: "1",
        cookName: "Maria's Kitchen",
        dishName: "Homemade Lasagna",
        cuisine: .italian,
        price: 12.50,
        pickupTime: "18:00",
        pickupDate: "2024-01-15",
        maxOrders: 20,
        currentOrders: 15,
        imageURL: nil
    ))
}
