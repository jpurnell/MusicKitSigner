//
//  generateToken.swift
//  MusicKit_Signer_CLI
//
//  Created by Justin Purnell on 2/16/24.
//

import Foundation

func generateToken(keyID: String, teamID: String, issueDate: Date = Date(), expirationDate: Date = Date().advanced(by: 15777000)) throws -> String {
	let now = String(Date().timeIntervalSince1970.rounded()).dropLast(2)
	let interval = expirationDate.timeIntervalSince1970 - issueDate.timeIntervalSince1970
	let exp = String(Date().addingTimeInterval(interval).timeIntervalSince1970.rounded()).dropLast(2)
	let temp = "/" + FileManager().temporaryDirectory.pathComponents.dropFirst().joined(separator: "/") +  "/"
	let downloads = "/" + FileManager().homeDirectoryForCurrentUser.pathComponents.dropFirst().joined(separator: "/") +  "/Downloads/"

	let header = try safeShell("echo -n '{\"alg\":\"ES256\",\"kid\":\"\(keyID)\"}' | base64 | sed s/\\+/-/ | sed -E s/=+$//").replacingOccurrences(of: "\n", with: "")
	let claims = try safeShell("echo -n '{\"iss\":\"\(teamID)\",\"iat\":\(now),\"exp\":\(exp)}' | base64 | sed s/\\+/-/ | sed -E s/=+$//").replacingOccurrences(of: "\n", with: "")
	let first = try safeShell("echo -n \"\(header).\(claims)\" | openssl dgst -sha256 -binary -sign \(downloads)AuthKey_\(keyID).p8 -out \(temp)signature.bin").replacingOccurrences(of: "\n", with: "")

	let asn1 = try safeShell("openssl asn1parse -in \(temp)signature.bin -inform DER > \(temp)asn1")
	let hex = try safeShell("cat \(temp)asn1 | perl -n -e'/INTEGER           :([0-9A-Z]*)$/ && print $1' > \(temp)signature.hex")
	let signature = try safeShell("cat \(temp)signature.hex | xxd -p -r | base64 | tr -d '\n=' | tr -- '+/' '-_'")
	let token = "\(header).\(claims).\(signature)".replacingOccurrences(of: "\n", with: "")
	return token
}
