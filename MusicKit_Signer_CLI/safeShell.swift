//
//  safeShell.swift
//  MusicKit_Signer_CLI
//
//  Created by Justin Purnell on 2/16/24.
//

import Foundation

@discardableResult // Add to suppress warnings when you don't want/need a result
func safeShell(_ command: String) throws -> String {
	let process = Process()
	let pipe = Pipe()
	
	process.standardOutput = pipe
	process.standardError = pipe
	process.arguments = ["-c", command]
	process.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
	process.standardInput = nil

	do {
		process.launch()
		process.waitUntilExit()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		if let output = String(data: data, encoding: .utf8) {
			return output
		}
	}
	
	return ""
}
