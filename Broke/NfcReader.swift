//
//  NfcReader.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//  Modified by OpenClaw
//

import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var message = "Waiting for NFC tag..."
    var session: NFCTagReaderSession?
    var onScanComplete: ((String) -> Void)?
    var onWriteComplete: ((Bool) -> Void)?
    
    func scan(completion: @escaping (String) -> Void) {
        self.onScanComplete = completion
        startSession()
    }
    
    // Kept for interface compatibility but disabled
    func write(_ text: String, completion: @escaping (Bool) -> Void) {
        self.onWriteComplete = completion
        // Fail immediately as we don't support writing in this mode
        completion(false)
    }
    
    private func startSession() {
        guard NFCTagReaderSession.readingAvailable else {
            NSLog("NFC is not available on this device")
            return
        }
        
        // Poll for all common tag types
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self, queue: nil)
        session?.alertMessage = "Hold your iPhone near any NFC tag."
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // Session started
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                NSLog("Session invalidated with error: \(error.localizedDescription)")
            }
        }
        self.session = nil
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tag detected. Please try again."
            session.restartPolling()
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                return
            }
            
            // Extract UID from the tag
            var uid: String?
            switch tag {
            case .iso7816(let t):
                uid = t.identifier.map { String(format: "%02hhX", $0) }.joined()
            case .feliCa(let t):
                uid = t.currentIDm.map { String(format: "%02hhX", $0) }.joined()
            case .iso15693(let t):
                uid = t.identifier.map { String(format: "%02hhX", $0) }.joined()
            case .miFare(let t):
                uid = t.identifier.map { String(format: "%02hhX", $0) }.joined()
            @unknown default:
                uid = nil
            }
            
            if let uid = uid {
                DispatchQueue.main.async {
                    self.message = "Tag Detected: \(uid)"
                    self.onScanComplete?(uid)
                }
                session.alertMessage = "Tag Scanned Successfully!"
                session.invalidate()
            } else {
                session.invalidate(errorMessage: "Could not read tag ID.")
            }
        }
    }
}
