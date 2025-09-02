import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417), // Zurich
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedDrop: Drop?
    @State private var showingDropDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: sampleDrops) { drop in
                    MapAnnotation(coordinate: drop.coordinate ?? CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417)) {
                        DropAnnotationView(drop: drop) {
                            selectedDrop = drop
                            showingDropDetail = true
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Search overlay
                VStack {
                    SearchBar(text: .constant(""))
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDropDetail) {
                if let drop = selectedDrop {
                    DropDetailView(drop: drop)
                }
            }
        }
    }
    
    private var sampleDrops: [Drop] {
        [
            Drop(id: "1", cookName: "Maria's Kitchen", dishName: "Homemade Lasagna", cuisine: .italian, price: 12.50, pickupTime: "18:00", pickupDate: "2024-01-15", maxOrders: 20, currentOrders: 15, imageURL: nil),
            Drop(id: "2", cookName: "Ahmed's Delights", dishName: "Biryani Rice", cuisine: .indian, price: 15.00, pickupTime: "19:00", pickupDate: "2024-01-15", maxOrders: 25, currentOrders: 22, imageURL: nil),
            Drop(id: "3", cookName: "Kim's Korean", dishName: "Kimbap Rolls", cuisine: .korean, price: 8.50, pickupTime: "17:30", pickupDate: "2024-01-15", maxOrders: 30, currentOrders: 18, imageURL: nil)
        ]
    }
}

struct DropAnnotationView: View {
    let drop: Drop
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .background(Color.white)
                    .clipShape(Circle())
                
                Text(drop.dishName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
    }
}

#Preview {
    MapView()
}
