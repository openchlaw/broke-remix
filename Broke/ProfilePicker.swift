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
    @State private var showAddProfileView = false
    @State private var editingProfile: Profile?
    
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 16)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Select Profile")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(profileManager.profiles) { profile in
                        ProfileCell(
                            profile: profile,
                            isSelected: profile.id == profileManager.currentProfileId
                        )
                        .onTapGesture {
                            withAnimation {
                                profileManager.setCurrentProfile(id: profile.id)
                            }
                        }
                        .onLongPressGesture {
                            editingProfile = profile
                        }
                    }
                    
                    // "Add New" Button
                    AddProfileCell()
                        .onTapGesture {
                            showAddProfileView = true
                        }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            Divider()
            
            Text("Long press a profile to edit")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .background(Color(Constants.Colors.profileSectionBackground))
        // Edit Sheet
        .sheet(item: $editingProfile) { profile in
            ProfileFormView(profile: profile, profileManager: profileManager) {
                editingProfile = nil
            }
        }
        // Add Sheet
        .sheet(isPresented: $showAddProfileView) {
            ProfileFormView(profileManager: profileManager) {
                showAddProfileView = false
            }
        }
    }
}

// MARK: - Subviews

struct ProfileCell: View {
    let profile: Profile
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: profile.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(profile.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(isSelected ? .white : .primary)
            
            HStack(spacing: 4) {
                Label("\(profile.appTokens.count)", systemImage: "app")
                Text("|")
                Label("\(profile.categoryTokens.count)", systemImage: "folder")
            }
            .font(.caption2)
            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddProfileCell: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: Constants.Icons.addIcon)
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("New Profile")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(.blue.opacity(0.5))
        )
        .background(Color.blue.opacity(0.05).cornerRadius(12))
    }
}
