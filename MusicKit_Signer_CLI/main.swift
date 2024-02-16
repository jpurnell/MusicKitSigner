//
//  main.swift
//  MusicKit_Signer_CLI
//
//  Created by Justin Purnell on 2/16/24.
//

import Foundation
import ArgumentParser

struct Signer: ParsableCommand {
	static let configuration = CommandConfiguration(abstract: "A Swift command line utility to generate a signed token for MusicKit. Verifies the key with Apple. Use it after downloading your key from Apple, per https://developer.apple.com/help/account/configure-app-capabilities/create-a-media-identifier-and-private-key/", subcommands: [])
	init() {}
	
	@Argument(help: "The keyID of the Key generated in the developer portal")
	private var keyID: String
	
	@Argument(help: "The Developer Team ID")
	public var devID: String
	
	public func run() throws {
		let token = try generateToken(keyID: keyID, teamID: devID)
		guard let success = try? safeShell("curl -H 'Authorization: Bearer \(token)' \"https://api.music.apple.com/v1/catalog/us/songs/1624945512\"") else { print("could not generate token"); return }
		if success.localizedStandardContains("Whenever You Need Somebody") {
			print(token)
			return
		}
		return
	}
}

Signer.main()
