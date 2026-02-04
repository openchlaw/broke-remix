//
//  EditProfileView.swift
//  Broke
//
//  Created by Oz Tamir on 23/08/2024.
//  Refactored by OpenClaw on 04/02/2026.
//

import SwiftUI
import SFSymbolsPicker
import FamilyControls

struct ProfileFormView: View {
    @ObservedObject var profileManager: ProfileManager
    
    // Form State
    @State private var profileName: String
    @State private var profileIcon: String
    @State private var activitySelection: FamilyActivitySelection
    
    // UI Triggers
    @State private var showSymbolsPicker = false
    @State private var showAppSelection = false
    @State private var showDeleteConfirmation = false
    
    let profile: Profile?
    let onDismiss: () -> Void
    
    init(profile: Profile? = nil, profileManager: ProfileManager, onDismiss: @escaping () -> Void) {
        self.profile = profile
        self.profileManager = profileManager
        self.onDismiss = onDismiss
        
        // Initialize State
        _profileName = State(initialValue: profile?.name ?? "")
        _profileIcon = State(initialValue: profile?.icon ?? Constants.Icons.defaultIcon)
        
        var selection = FamilyActivitySelection()
        selection.applicationTokens = profile?.appTokens ?? []
        selection.categoryTokens = profile?.categoryTokens ?? []
        _activitySelection = State(initialValue: selection)
    }
    
    var body: some View {
        NavigationView {
            Form {
                detailsSection
                appsSection
                
                if profile != nil {
                    deleteSection
                }
            }
            .navigationTitle(profile == nil ? "Add Profile" : "Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel", action: onDismiss),
                trailing: Button("Save", action: handleSave).disabled(profileName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
            .sheet(isPresented: $showSymbolsPicker) {
                SymbolsPicker(selection: $profileIcon, title: "Pick an icon", autoDismiss: true)
            }
            .sheet(isPresented: $showAppSelection) {
                NavigationView {
                    FamilyActivityPicker(selection: $activitySelection)
                        .navigationTitle("Select Apps")
                        .navigationBarItems(trailing: Button("Done") { showAppSelection = false })
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Profile"),
                    message: Text("Are you sure? This cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let profile = profile {
                            profileManager.deleteProfile(withId: profile.id)
                        }
                        onDismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // MARK: - Sections
    
    private var detailsSection: some View {
        Section(header: Text("Profile Details")) {
            TextField("Profile Name", text: $profileName)
            
            Button(action: { showSymbolsPicker = true }) {
                HStack {
                    Image(systemName: profileIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                    
                    Text("Choose Icon")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var appsSection: some View {
        Section(header: Text("Configuration")) {
            Button(action: { showAppSelection = true }) {
                HStack {
                    Text("Select Apps & Categories")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Apps Blocked")
                Spacer()
                Text("\(activitySelection.applicationTokens.count)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Categories Blocked")
                Spacer()
                Text("\(activitySelection.categoryTokens.count)")
                    .foregroundColor(.secondary)
            }
            
            Text("Due to Apple's privacy restrictions, the specific names of blocked apps cannot be displayed here.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(action: { showDeleteConfirmation = true }) {
                HStack {
                    Spacer()
                    Text("Delete Profile")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSave() {
        let name = profileName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        
        if let existingProfile = profile {
            profileManager.updateProfile(
                id: existingProfile.id,
                name: name,
                appTokens: activitySelection.applicationTokens,
                categoryTokens: activitySelection.categoryTokens,
                icon: profileIcon
            )
        } else {
            let newProfile = Profile(
                name: name,
                appTokens: activitySelection.applicationTokens,
                categoryTokens: activitySelection.categoryTokens,
                icon: profileIcon
            )
            profileManager.addProfile(newProfile)
        }
        onDismiss()
    }
}
