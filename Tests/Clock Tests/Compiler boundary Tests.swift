#if os(macOS)
import Foundation
import Testing

private final class CompilerBoundaryBundle: NSObject {}

@Test
func `The compiler enforces domain and dimension boundaries`() throws {
    let tests = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    let script = tests.appendingPathComponent("Typechecking/Verify.swift")
    let products = Bundle(for: CompilerBoundaryBundle.self).bundleURL.deletingLastPathComponent()
    let scratch = FileManager.default.temporaryDirectory
        .appendingPathComponent("clock-compiler-test-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = [
        "swift", "-module-cache-path", scratch.path, script.path, products.path,
    ]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    let diagnostics = String(decoding: data, as: UTF8.self)
    #expect(process.terminationStatus == 0, "\(diagnostics)")
}
#endif
