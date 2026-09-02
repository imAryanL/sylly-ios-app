//
//  Config.swift
//  Sylly
//
//  Reads API keys from Secrets.xcconfig (via Info.plist).
//  The xcconfig file is gitignored so secrets never end up in source control.
//

import Foundation

struct Config {
    // Reads the CLAUDE_API_KEY value that was set in Secrets.xcconfig
    // The value flows: Secrets.xcconfig → Info.plist → Bundle → here
    static let claudeAPIKey: String = {
        guard let key = Bundle.main.infoDictionary?["CLAUDE_API_KEY"] as? String,
              !key.isEmpty else {
            fatalError("Missing CLAUDE_API_KEY. Create Secrets.xcconfig with your API key. See README for setup.")
        }
        return key
    }()
}
