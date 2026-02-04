//
//  BrockerView.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//  Modified by OpenClaw
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
    @AppStorage("lockedTagID") private var lockedTagID: String = ""
    
    @State private var showWrongTagAlert = false
    
    private var isBlocking : Bool {
        get {
            return appBlocker.isBlocking
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        blockOrUnblockButton(geometry: geometry)
                        
                        if !isBlocking {
                            Divider()
                            
                            ProfilesPicker(profileManager: profileManager)
                                .frame(height: geometry.size.height / 2)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .background(isBlocking ? Color("BlockingBackground") : Color("NonBlockingBackground"))
                }
            }
            // Removed trailing Create Tag button as any tag works now
            .alert(isPresented: $showWrongTagAlert) {
                Alert(
                    title: Text("Wrong Tag"),
                    message: Text("This tag does not match the one used to lock."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .animation(.spring(), value: isBlocking)
    }
    
    @ViewBuilder
    private func blockOrUnblockButton(geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            Text(statusText)
                .font(.caption)
                .opacity(0.75)
                .transition(.scale)
            
            Button(action: {
                withAnimation(.spring()) {
                    scanTag()
                }
            }) {
                Image(isBlocking ? "RedIcon" : "GreenIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: geometry.size.height / 3)
            }
            .transition(.scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: isBlocking ? geometry.size.height : geometry.size.height / 2)
        .animation(.spring(), value: isBlocking)
    }
    
    private var statusText: String {
        if isBlocking {
            return "Scan the lock tag to unblock"
        } else {
            return "Scan any tag to lock"
        }
    }
    
    private func scanTag() {
        nfcReader.scan { uid in
            if isBlocking {
                // Verification Mode: Check if scanned UID matches the lock UID
                if uid == lockedTagID {
                    NSLog("Unblocking with correct tag")
                    appBlocker.toggleBlocking(for: profileManager.currentProfile)
                    lockedTagID = "" // Clear lock so a different tag can be used next time
                } else {
                    showWrongTagAlert = true
                    NSLog("Wrong Tag! Expected: \(lockedTagID), Got: \(uid)")
                }
            } else {
                // Registration/Lock Mode: Register the scanned tag as the key
                NSLog("Locking with tag: \(uid)")
                lockedTagID = uid
                appBlocker.toggleBlocking(for: profileManager.currentProfile)
            }
        }
    }
}
