//
//  Constants.swift
//  Broke
//
//  Created by OpenClaw Refactor on 04/02/2026.
//

import Foundation
import SwiftUI

enum Constants {
    enum Keys {
        static let savedProfiles = "savedProfiles"
        static let currentProfileId = "currentProfileId"
        static let isBlocking = "isBlocking"
        static let lockedTagID = "lockedTagID"
    }
    
    enum Colors {
        static let blockingBackground = "BlockingBackground"
        static let nonBlockingBackground = "NonBlockingBackground"
        static let profileSectionBackground = "ProfileSectionBackground"
    }
    
    enum Icons {
        static let defaultIcon = "bell.slash"
        static let addIcon = "plus"
        static let redIcon = "RedIcon"
        static let greenIcon = "GreenIcon"
    }
    
    enum Defaults {
        static let defaultProfileName = "Default"
    }
}
