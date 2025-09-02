import SwiftUI

struct ContentView: View {
    @State private var currentUserRole: UserRole = .buyer
    
    var body: some View {
        TabView {
            Group {
                if currentUserRole == .buyer {
                    BuyerHomeView()
                } else {
                    CookDashboardView()
                }
            }
            .tabItem {
                Image(systemName: currentUserRole == .buyer ? "house.fill" : "fork.knife")
                Text(currentUserRole == .buyer ? "Home" : "Dashboard")
            }
            
            if currentUserRole == .buyer {
                MapView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }
                
                OrdersView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Orders")
                    }
            }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.orange)
        .environmentObject(UserRoleManager(currentRole: currentUserRole))
    }
}

// MARK: - User Role Manager
class UserRoleManager: ObservableObject {
    @Published var currentRole: UserRole
    
    init(currentRole: UserRole) {
        self.currentRole = currentRole
    }
    
    func switchRole() {
        currentRole = currentRole == .buyer ? .cook : .buyer
    }
}

#Preview {
    ContentView()
}
