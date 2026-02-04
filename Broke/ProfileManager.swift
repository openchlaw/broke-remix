//
//  ProfileManager.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//  Refactored by OpenClaw on 04/02/2026.
//

import Foundation
import FamilyControls
import ManagedSettings

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var currentProfileId: UUID?
    
    // Computed property to safely get the current profile
    var currentProfile: Profile {
        if let id = currentProfileId, let profile = profiles.first(where: { $0.id == id }) {
            return profile
        }
        // Fallback to the first available profile or a temporary default
        return profiles.first ?? Profile.createDefault()
    }
    
    init() {
        loadProfiles()
        ensureDefaultProfile()
    }
    
    // MARK: - Persistence
    
    func loadProfiles() {
        // Load Profiles
        if let savedProfiles = UserDefaults.standard.data(forKey: Constants.Keys.savedProfiles) {
            do {
                profiles = try JSONDecoder().decode([Profile].self, from: savedProfiles)
            } catch {
                NSLog("Failed to decode profiles: \(error.localizedDescription)")
                profiles = []
            }
        }
        
        // Load Current ID
        if let savedIdString = UserDefaults.standard.string(forKey: Constants.Keys.currentProfileId),
           let uuid = UUID(uuidString: savedIdString) {
            currentProfileId = uuid
        } else {
            currentProfileId = profiles.first?.id
        }
    }
    
    private func saveProfiles() {
        do {
            let encoded = try JSONEncoder().encode(profiles)
            UserDefaults.standard.set(encoded, forKey: Constants.Keys.savedProfiles)
            UserDefaults.standard.set(currentProfileId?.uuidString, forKey: Constants.Keys.currentProfileId)
        } catch {
            NSLog("Failed to encode profiles: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Profile Management
    
    func addProfile(_ profile: Profile) {
        profiles.append(profile)
        // Automatically switch to the new profile
        currentProfileId = profile.id
        saveProfiles()
    }
    
    func updateProfile(id: UUID, name: String? = nil, appTokens: Set<ApplicationToken>? = nil, categoryTokens: Set<ActivityCategoryToken>? = nil, icon: String? = nil) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        
        var profile = profiles[index]
        if let name = name { profile.name = name }
        if let appTokens = appTokens { profile.appTokens = appTokens }
        if let categoryTokens = categoryTokens { profile.categoryTokens = categoryTokens }
        if let icon = icon { profile.icon = icon }
        
        profiles[index] = profile
        
        // If we updated the current profile, ensure ID consistency (though ID shouldn't change)
        if currentProfileId == id {
            currentProfileId = profile.id
        }
        
        saveProfiles()
    }
    
    func setCurrentProfile(id: UUID) {
        if profiles.contains(where: { $0.id == id }) {
            currentProfileId = id
            saveProfiles()
        }
    }
    
    func deleteProfile(withId id: UUID) {
        profiles.removeAll { $0.id == id }
        
        // If we deleted the current profile, switch to the first available one
        if currentProfileId == id {
            currentProfileId = profiles.first?.id
        }
        
        ensureDefaultProfile() // Ensure we never have 0 profiles
        saveProfiles()
    }
    
    private func ensureDefaultProfile() {
        if profiles.isEmpty {
            let defaultProfile = Profile.createDefault()
            profiles.append(defaultProfile)
            currentProfileId = defaultProfile.id
            saveProfiles()
        } else if currentProfileId == nil {
            // Self-healing: if ID is missing but profiles exist, pick the first one
            currentProfileId = profiles.first?.id
            saveProfiles()
        }
    }
}

// MARK: - Profile Model

struct Profile: Identifiable, Codable {
    let id: UUID
    var name: String
    var appTokens: Set<ApplicationToken>
    var categoryTokens: Set<ActivityCategoryToken>
    var icon: String

    init(id: UUID = UUID(), name: String, appTokens: Set<ApplicationToken>, categoryTokens: Set<ActivityCategoryToken>, icon: String = Constants.Icons.defaultIcon) {
        self.id = id
        self.name = name
        self.appTokens = appTokens
        self.categoryTokens = categoryTokens
        self.icon = icon
    }
    
    static func createDefault() -> Profile {
        return Profile(
            name: Constants.Defaults.defaultProfileName,
            appTokens: [],
            categoryTokens: [],
            icon: Constants.Icons.defaultIcon
        )
    }
}
