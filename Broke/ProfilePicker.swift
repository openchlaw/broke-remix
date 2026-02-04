//
//  ProfilePicker.swift
//  Broke
//
//  Created by Oz Tamir on 23/08/2024.
//  Refactored by OpenClaw on 04/02/2026.
//

import SwiftUI
import FamilyControls

struct ProfilesPicker: View {
    @ObservedObject var profileManager: ProfileManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddProfileView = false
    @State private var editingProfile: Profile?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(profileManager.profiles) { profile in
                        Button(action: {
                            profileManager.setCurrentProfile(id: profile.id)
                            Haptics.selection()
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(profile.id == profileManager.currentProfileId ? Color.blue : Color.gray.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: profile.icon)
                                        .foregroundColor(profile.id == profileManager.currentProfileId ? .white : .blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(profile.appTokens.count) Apps • \(profile.categoryTokens.count) Categories")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if profile.id == profileManager.currentProfileId {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                profileManager.deleteProfile(withId: profile.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                editingProfile = profile
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                        .contextMenu {
                            Button {
                                editingProfile = profile
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                profileManager.deleteProfile(withId: profile.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("Select a Profile")
                }
                
                Section {
                    Button(action: { showAddProfileView = true }) {
                        Label("Create New Profile", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingProfile) { profile in
                ProfileFormView(profile: profile, profileManager: profileManager) {
                    editingProfile = nil
                }
            }
            .sheet(isPresented: $showAddProfileView) {
                ProfileFormView(profileManager: profileManager) {
                    showAddProfileView = false
                }
            }
        }
    }
}
