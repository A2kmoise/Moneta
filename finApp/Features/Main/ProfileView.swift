import SwiftUI

// Assuming FintrackTheme and associated colors are defined elsewhere

// MARK: - Reusable Setting Rows (Defined outside ProfileView to be accessible)

struct SettingsHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundColor(FintrackTheme.textSecondary)
            .padding(.leading, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
}

struct SettingsIcon: View {
    let icon: String
    let color: Color
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundColor(.white)
            .padding(6)
            .background(color)
            .cornerRadius(8)
    }
}

struct ToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            SettingsIcon(icon: icon, color: iconColor)
            Text(title)
                .foregroundColor(FintrackTheme.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: FintrackTheme.primaryGreen))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}


// MARK: - Core View

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var notificationsEnabled: Bool = true
    @State private var marketingEnabled: Bool = false
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: 1. User Account Card
                    NavigationLink(destination: EditProfileView()) {
                        userCard
                    }
                    .buttonStyle(PlainButtonStyle())

                    // MARK: 2. Core Settings (Notifications Group)
                    notificationsSection

                    appearanceSection
                    
                    Spacer()
                    
                    // MARK: 3. Logout
                    logoutButton
                }
                .padding(FintrackUI.screenPadding)
                .padding(.bottom, 30)
            }
            .background(FintrackTheme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Components Extension

private extension ProfileView {
    
    // --- User Card (Information) ---
    var userCard: some View {
        VStack {
            HStack(spacing: 16) {
                // Larger Avatar
                Circle()
                    .fill(FintrackTheme.primaryGreen.opacity(0.2))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(FintrackTheme.primaryGreen)
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fit)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.currentUserName.isEmpty ? "User" : authViewModel.currentUserName)
                        .font(.title2.weight(.bold))
                        .foregroundColor(FintrackTheme.textPrimary)
                    Text(authViewModel.currentUserEmail.isEmpty ? "user@email.com" : authViewModel.currentUserEmail)
                        .font(.subheadline)
                        .foregroundColor(FintrackTheme.textSecondary)
                }

                Spacer()
                
                // Disclosure indicator
                Image(systemName: "chevron.right")
                    .foregroundColor(FintrackTheme.textSecondary)
            }
            .padding(20)
        }
        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadiusLarge)
    }

    // --- Notifications Section ---
    var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // FIX: SettingsHeader is now accessible
            SettingsHeader(title: "Notifications")
            
            // FIX: ToggleRow is now accessible
            ToggleRow(title: "Spending Alerts", icon: "bell.badge.fill", iconColor: .pink, isOn: $notificationsEnabled)
            
            Divider().padding(.leading, 50)
            
            // FIX: ToggleRow is now accessible
            ToggleRow(title: "Product Updates & Offers", icon: "megaphone.fill", iconColor: .yellow, isOn: $marketingEnabled)

            Text("Control which financial alerts and product information you receive.")
                .font(.caption)
                .foregroundColor(FintrackTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
    }

    var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsHeader(title: "Appearance")

            HStack {
                SettingsIcon(icon: "moon.stars.fill", color: .purple)

                Text("Mode")
                    .foregroundColor(FintrackTheme.textPrimary)

                Spacer()

                Picker("Mode", selection: $appColorScheme) {
                    ForEach(AppColorScheme.allCases) { scheme in
                        Text(scheme.title).tag(scheme)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Text("Choose System, Light, or Dark mode.")
                .font(.caption)
                .foregroundColor(FintrackTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
    }
    
    // --- Logout Button ---
    var logoutButton: some View {
        Button(action: {
            authViewModel.signOut()
        }) {
            Text("Log Out")
                .font(.headline.weight(.semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
        }
    }
}

// MARK: - Edit Profile View (Kept for navigation destination)

struct EditProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName: String = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                // Profile Photo Area
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(FintrackTheme.primaryGreen)
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fit)
                    
                    Button("Change Photo") {
                        // Action to open photo library/camera
                    }
                    .font(.subheadline)
                    .foregroundColor(FintrackTheme.primaryGreen)
                }
                
                // Account Information Fields
                VStack(spacing: 16) {
                    editField(label: "Full Name", text: $fullName, icon: "person", isSecure: false)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(FintrackTheme.textSecondary)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(FintrackTheme.textSecondary)
                            
                            Text(authViewModel.currentUserEmail)
                                .foregroundColor(FintrackTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("Cannot be changed")
                            .font(.caption2)
                            .foregroundColor(FintrackTheme.textSecondary)
                    }
                    .padding(.vertical, 8)
                }
                .fintrackCard(cornerRadius: FintrackUI.cardCornerRadius)
                
                // Password Fields
                VStack(spacing: 16) {
                    Text("Change Password (Optional)")
                        .font(.headline)
                        .foregroundColor(FintrackTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    editField(label: "Current Password", text: $currentPassword, icon: "lock", isSecure: true)
                    editField(label: "New Password", text: $newPassword, icon: "key", isSecure: true)
                    
                    if !newPassword.isEmpty && newPassword.count < 6 {
                        Text("Password must be at least 6 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if !newPassword.isEmpty && currentPassword.isEmpty {
                        Text("Current password is required to change password")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .fintrackCard(cornerRadius: FintrackUI.cardCornerRadius)
                
                // Save Button
                Button(action: {
                    saveProfile()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Save Changes")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isValid ? FintrackTheme.primaryGreen : FintrackTheme.primaryGreen.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: FintrackUI.controlCornerRadius, style: .continuous))
                .disabled(!isValid || isLoading)
            }
            .padding(FintrackUI.screenPadding)
        }
        .background(FintrackTheme.background.ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .onAppear {
            fullName = authViewModel.currentUserName
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Profile updated successfully")
        }
    }
    
    private var isValid: Bool {
        let nameChanged = !fullName.isEmpty && fullName != authViewModel.currentUserName
        
        // Password validation: if changing password, need current password and new password must be valid
        let passwordValid: Bool
        if !newPassword.isEmpty {
            passwordValid = !currentPassword.isEmpty && newPassword.count >= 6
        } else {
            passwordValid = true
        }
        
        let hasChanges = nameChanged || !newPassword.isEmpty
        return hasChanges && passwordValid
    }
    
    private func saveProfile() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                let nameToUpdate = fullName != authViewModel.currentUserName ? fullName : nil
                let currentPasswordToSend = !newPassword.isEmpty ? currentPassword : nil
                let passwordToUpdate = !newPassword.isEmpty ? newPassword : nil
                
                try await authViewModel.updateProfile(fullName: nameToUpdate, currentPassword: currentPasswordToSend, password: passwordToUpdate)
                
                await MainActor.run {
                    isLoading = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to update profile. Please try again."
                }
            }
        }
    }
    
    private func editField(label: String, text: Binding<String>, icon: String, isSecure: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(FintrackTheme.textSecondary)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(FintrackTheme.textSecondary)
                
                if isSecure {
                    SecureField(label, text: text)
                        .foregroundColor(FintrackTheme.textPrimary)
                } else {
                    TextField(label, text: text)
                        .foregroundColor(FintrackTheme.textPrimary)
                }
            }
        }
        .padding(.vertical, 8)
        .overlay(
            VStack {
                Spacer()
                Divider()
            }.padding(.leading, 24)
            , alignment: .bottom
        )
    }
}


// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
