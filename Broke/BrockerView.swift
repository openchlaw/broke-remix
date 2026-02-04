//
//  BrockerView.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//  Refactored by OpenClaw on 04/02/2026.
//
import SwiftUI
import CoreNFC
import SFSymbolsPicker
import FamilyControls
import ManagedSettings

struct BrokerView: View {
    @EnvironmentObject private var appBlocker: AppBlocker
    @EnvironmentObject private var profileManager: ProfileManager
    @StateObject private var nfcReader = NFCReader()
    
    // Persist the UID of the locking tag
    @AppStorage(Constants.Keys.lockedTagID) private var lockedTagID: String = ""
    
    @State private var showWrongTagAlert = false
    @State private var wrongTagUID: String?
    
    private var isBlocking: Bool {
        appBlocker.isBlocking
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Main Status/Action Area
                    StatusView(
                        isBlocking: isBlocking,
                        statusText: statusText,
                        geometry: geometry,
                        onTap: scanTag
                    )
                    
                    // Profile Picker (Hidden when blocked)
                    if !isBlocking {
                        Divider()
                        ProfilesPicker(profileManager: profileManager)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(
                    (isBlocking ? Color(Constants.Colors.blockingBackground) : Color(Constants.Colors.nonBlockingBackground))
                        .ignoresSafeArea()
                )
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showWrongTagAlert) {
                Alert(
                    title: Text("Access Denied"),
                    message: Text("This tag does not match the key used to lock the app.\n\nExpected Key: ...\(String(lockedTagID.suffix(4)))\nScanned: ...\(String((wrongTagUID ?? "").suffix(4)))"),
                    dismissButton: .default(Text("Try Again"))
                )
            }
        }
        .animation(.spring(), value: isBlocking)
    }
    
    private var statusText: String {
        if isBlocking {
            return "Scan your key tag to unlock"
        } else {
            return "Tap to lock with any NFC tag"
        }
    }
    
    private func scanTag() {
        nfcReader.scan { uid in
            DispatchQueue.main.async {
                handleScanResult(uid: uid)
            }
        }
    }
    
    private func handleScanResult(uid: String) {
        if isBlocking {
            // UNLOCK LOGIC
            if uid == lockedTagID {
                appBlocker.toggleBlocking(for: profileManager.currentProfile)
                lockedTagID = "" // Clear the lock
            } else {
                // Wrong tag
                wrongTagUID = uid
                showWrongTagAlert = true
            }
        } else {
            // LOCK LOGIC
            lockedTagID = uid
            appBlocker.toggleBlocking(for: profileManager.currentProfile)
        }
    }
}

// MARK: - Subviews

struct StatusView: View {
    let isBlocking: Bool
    let statusText: String
    let geometry: GeometryProxy
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(statusText)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isBlocking ? .white.opacity(0.9) : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                withAnimation(.spring()) {
                    onTap()
                }
            }) {
                Image(isBlocking ? Constants.Icons.redIcon : Constants.Icons.greenIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: isBlocking ? geometry.size.height * 0.4 : geometry.size.height * 0.3)
                    .shadow(color: isBlocking ? Color.red.opacity(0.4) : Color.green.opacity(0.4), radius: 20, x: 0, y: 10)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: isBlocking ? geometry.size.height : geometry.size.height * 0.55)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
