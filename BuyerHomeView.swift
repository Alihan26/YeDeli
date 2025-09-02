import SwiftUI

struct BuyerHomeView: View {
    @State private var searchText = ""
    @State private var selectedCuisine: CuisineType = .all
    @State private var upcomingDrops: [Drop] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search and Filter Section
                    VStack(spacing: 15) {
                        SearchBar(text: $searchText)
                        
                        CuisineFilterView(selectedCuisine: $selectedCuisine)
                    }
                    .padding(.horizontal)
                    
                    // Featured Drops Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Featured Drops")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("See All") {
                                // Navigate to all drops
                            }
                            .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(upcomingDrops.prefix(5)) { drop in
                                    FeaturedDropCard(drop: drop)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Orders Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Orders")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 10) {
                            ForEach(0..<3) { _ in
                                RecentOrderRow()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("YeDeli")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadUpcomingDrops()
        }
    }
    
    private func loadUpcomingDrops() {
        // TODO: Load from API
        upcomingDrops = [
            Drop(id: "1", cookName: "Maria's Kitchen", dishName: "Homemade Lasagna", cuisine: .italian, price: 12.50, pickupTime: "18:00", pickupDate: "2024-01-15", maxOrders: 20, currentOrders: 15, imageURL: nil),
            Drop(id: "2", cookName: "Ahmed's Delights", dishName: "Biryani Rice", cuisine: .indian, price: 15.00, pickupTime: "19:00", pickupDate: "2024-01-15", maxOrders: 25, currentOrders: 22, imageURL: nil),
            Drop(id: "3", cookName: "Kim's Korean", dishName: "Kimbap Rolls", cuisine: .korean, price: 8.50, pickupTime: "17:30", pickupDate: "2024-01-15", maxOrders: 30, currentOrders: 18, imageURL: nil)
        ]
    }
}

#Preview {
    BuyerHomeView()
}
