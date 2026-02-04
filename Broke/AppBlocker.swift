//
//  AppBlocker.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//  Refactored by OpenClaw on 04/02/2026.
//

import SwiftUI
import ManagedSettings
import FamilyControls

class AppBlocker: ObservableObject {
    private let store = ManagedSettingsStore()
    
    @Published var isBlocking = false
    @Published var isAuthorized = false
    
    init() {
        loadBlockingState()
        Task {
            await requestAuthorization()
        }
    }
    
    // MARK: - Authorization
    
    @MainActor
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            self.isAuthorized = true
        } catch {
            print("Authorization failed: \(error.localizedDescription)")
            self.isAuthorized = false
        }
    }
    
    // MARK: - Blocking Logic
    
    func toggleBlocking(for profile: Profile) {
        // Optimistic check, though the system might prompt if auth was revoked
        if !isAuthorized {
            Task { await requestAuthorization() }
        }
        
        isBlocking.toggle()
        saveBlockingState()
        applyBlockingSettings(for: profile)
    }
    
    private func applyBlockingSettings(for profile: Profile) {
        if isBlocking {
            print("Blocking enabled for profile: \(profile.name). Apps: \(profile.appTokens.count)")
            
            // Apply Application Shields
            if profile.appTokens.isEmpty {
                 store.shield.applications = nil
            } else {
                 store.shield.applications = profile.appTokens
            }
            
            // Apply Category Shields
            if profile.categoryTokens.isEmpty {
                store.shield.applicationCategories = .none
            } else {
                store.shield.applicationCategories = .specific(profile.categoryTokens)
            }
            
        } else {
            print("Blocking disabled. Clearing shields.")
            store.clearAllSettings()
        }
    }
    
    // MARK: - Persistence
    
    private func loadBlockingState() {
        isBlocking = UserDefaults.standard.bool(forKey: Constants.Keys.isBlocking)
    }
    
    private func saveBlockingState() {
        UserDefaults.standard.set(isBlocking, forKey: Constants.Keys.isBlocking)
    }
}
