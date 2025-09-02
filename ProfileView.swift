import SwiftUI

struct ProfileView: View {
    @State private var showingLogin = false
    @State private var isLoggedIn = false
    @State private var userProfile: UserProfile?
    
    var body: some View {
        NavigationView {
            if isLoggedIn {
                LoggedInProfileView(userProfile: userProfile)
            } else {
                GuestProfileView {
                    showingLogin = true
                }
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView {
                // Handle successful login
                isLoggedIn = true
                loadUserProfile()
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() {
        // TODO: Check if user is logged in
        isLoggedIn = false
    }
    
    private func loadUserProfile() {
        // TODO: Load user profile from API
        userProfile = sampleUser
    }
}

struct LoggedInProfileView: View {
    let userProfile: UserProfile?
    @EnvironmentObject var userRoleManager: UserRoleManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                    
                    VStack(spacing: 4) {
                        Text(userProfile?.name ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(userProfile?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Role Switcher
                VStack(spacing: 0) {
                    ProfileOptionRow(icon: userRoleManager.currentRole.icon, title: "Switch to \(userRoleManager.currentRole == .buyer ? "Cook" : "Buyer") Mode", action: {
                        userRoleManager.switchRole()
                    })
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Profile Options
                VStack(spacing: 0) {
                    ProfileOptionRow(icon: "person.fill", title: "Edit Profile", action: {})
                    ProfileOptionRow(icon: "location.fill", title: "Delivery Addresses", action: {})
                    ProfileOptionRow(icon: "creditcard.fill", title: "Payment Methods", action: {})
                    ProfileOptionRow(icon: "bell.fill", title: "Notifications", action: {})
                    ProfileOptionRow(icon: "questionmark.circle.fill", title: "Help & Support", action: {})
                    ProfileOptionRow(icon: "gear", title: "Settings", action: {})
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Logout Button
                Button("Logout") {
                    // Handle logout
                }
                .foregroundColor(.red)
                .padding()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct GuestProfileView: View {
    let loginAction: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Logo/Icon
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Welcome to YeDeli")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Discover homemade food from local cooks in your area")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                Button(action: loginAction) {
                    Text("Sign In / Sign Up")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                
                Button("Continue as Guest") {
                    // Handle guest mode
                }
                .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ProfileView()
}
