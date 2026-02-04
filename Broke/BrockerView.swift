//
//  BrockerView.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//  Refactored by OpenClaw on 04/02/2026.
//
import SwiftUI
import CoreNFC

struct BrokerView: View {
    @EnvironmentObject private var appBlocker: AppBlocker
    @EnvironmentObject private var profileManager: ProfileManager
    @StateObject private var nfcReader = NFCReader()
    
    @AppStorage(Constants.Keys.lockedTagID) private var lockedTagID: String = ""
    
    @State private var showWrongTagAlert = false
    @State private var wrongTagUID: String?
    @State private var showProfilesSheet = false
    
    private var isBlocking: Bool {
        appBlocker.isBlocking
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic Background
                (isBlocking ? Color.red.opacity(0.1) : Color(UIColor.systemBackground))
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Status Header
                    VStack(spacing: 12) {
                        Text(isBlocking ? "Phone Locked" : "Phone Unlocked")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(statusText)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Main Action Button (The "Lock/Unlock" Interface)
                    Button(action: scanTag) {
                        ZStack {
                            Circle()
                                .fill(isBlocking ? Color.red : Color.green)
                                .frame(width: 220, height: 220)
                                .shadow(color: (isBlocking ? Color.red : Color.green).opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: isBlocking ? "lock.fill" : "lock.open.fill")
                                .font(.system(size: 80, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    Spacer()
                    
                    // Footer / Profile Selector
                    if !isBlocking {
                        VStack(spacing: 16) {
                            Text("Current Profile")
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundColor(.secondary)
                            
                            Button(action: { showProfilesSheet = true }) {
                                HStack {
                                    Image(systemName: profileManager.currentProfile.icon)
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text(profileManager.currentProfile.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(profileManager.currentProfile.appTokens.count) Apps Blocked")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.tertiaryLabel)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    } else {
                        // Spacer to balance the layout when blocked
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfilesSheet) {
                ProfilesPicker(profileManager: profileManager)
            }
            .alert(isPresented: $showWrongTagAlert) {
                Alert(
                    title: Text("Access Denied"),
                    message: Text("This tag does not match the key used to lock."),
                    dismissButton: .default(Text("Try Again"))
                )
            }
            .onChange(of: isBlocking) { newValue in
                if newValue {
                    Haptics.notification(.success)
                } else {
                    Haptics.notification(.success)
                }
            }
        }
    }
    
    private var statusText: String {
        if isBlocking {
            return "Tap the lock and scan your key tag to restore access."
        } else {
            return "Tap the lock and scan any NFC tag to brick your phone."
        }
    }
    
    private func scanTag() {
        Haptics.play(.medium)
        nfcReader.scan { uid in
            DispatchQueue.main.async {
                handleScanResult(uid: uid)
            }
        }
    }
    
    private func handleScanResult(uid: String) {
        if isBlocking {
            if uid == lockedTagID {
                appBlocker.toggleBlocking(for: profileManager.currentProfile)
                lockedTagID = ""
            } else {
                wrongTagUID = uid
                showWrongTagAlert = true
                Haptics.notification(.error)
            }
        } else {
            lockedTagID = uid
            appBlocker.toggleBlocking(for: profileManager.currentProfile)
        }
    }
}

// MARK: - Styles

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// Helper to access UIColors in SwiftUI easily
extension Color {
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
}
