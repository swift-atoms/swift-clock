// Run with: swift Tests/Typechecking/Verify.swift /path/to/Build/Products/Debug
import Foundation

struct VerificationFailure: Error, CustomStringConvertible {
    let description: String
}

func verify() throws {
    guard CommandLine.arguments.count == 2 else {
        throw VerificationFailure(description: "Pass the atoms workspace Build/Products/Debug directory")
    }
    let products = URL(fileURLWithPath: CommandLine.arguments[1]).path
    let fixtures = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let scratch = FileManager.default.temporaryDirectory
        .appendingPathComponent("clock-domain-typecheck-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)

    func typecheck(_ fixture: URL) throws -> (status: Int32, diagnostics: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc", "-typecheck", "-swift-version", "6",
            "-enable-upcoming-feature", "MemberImportVisibility",
            "-enable-upcoming-feature", "InternalImportsByDefault",
            "-enable-experimental-feature", "Lifetimes",
            "-I", products, "-I", URL(fileURLWithPath: products).appendingPathComponent("Modules").path,
            "-module-cache-path", scratch.appendingPathComponent("modules").path,
            fixture.path,
        ]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: output, as: UTF8.self))
    }

    let validFixtures = try FileManager.default.contentsOfDirectory(
        at: fixtures, includingPropertiesForKeys: nil
    ).filter { $0.lastPathComponent.hasPrefix("Valid") && $0.pathExtension == "swift" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    guard !validFixtures.isEmpty else {
        throw VerificationFailure(description: "No valid compiler fixtures were found")
    }
    for fixture in validFixtures {
        let result = try typecheck(fixture)
        guard result.status == 0 else {
            throw VerificationFailure(description: "Valid client \(fixture.lastPathComponent) failed:\n\(result.diagnostics)")
        }
    }
    let invalid = try FileManager.default.contentsOfDirectory(
        at: fixtures, includingPropertiesForKeys: nil
    ).filter { $0.lastPathComponent.hasPrefix("Invalid") && $0.pathExtension == "swift" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    guard !invalid.isEmpty else {
        throw VerificationFailure(description: "No negative compiler fixtures were found")
    }
    for fixture in invalid {
        let source = try String(contentsOf: fixture, encoding: .utf8)
        let prefix = "// expected-error: "
        guard let firstLine = source.split(separator: "\n").first,
            firstLine.hasPrefix(prefix)
        else {
            throw VerificationFailure(description: "Missing diagnostic expectation: \(fixture.path)")
        }
        let expected = String(firstLine.dropFirst(prefix.count))
        let result = try typecheck(fixture)
        guard result.status != 0, result.diagnostics.contains(expected) else {
            throw VerificationFailure(description: "Unexpected result for \(fixture.lastPathComponent):\n\(result.diagnostics)")
        }
    }
    print("Clock domain boundary: valid client accepted; \(invalid.count) invalid programs rejected.")
}

do {
    try verify()
} catch {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(1)
}
