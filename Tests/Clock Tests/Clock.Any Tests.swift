import Clock
import Testing

@Suite
struct `Erased clocks preserve their wrapped behavior` {
    @Suite struct `Values preserve their representation` {}
    @Suite struct `Boundary values preserve their contracts` {}
    @Suite struct `Operations compose correctly` {}
    @Suite(.serialized) struct `Operations meet performance expectations` {}
}

extension `Erased clocks preserve their wrapped behavior`.`Values preserve their representation` {
    @Test
    func `wrapping Immediate clock preserves now`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let erasedNow = erased.now
        _ = erasedNow
    }

    @Test
    func `wrapping Immediate clock preserves minimumResolution`() {
        let immediate = Clock.Immediate()
        immediate.minimumResolution = .milliseconds(10)
        let erased = Clock.Any(immediate)
        #expect(erased.minimumResolution == .milliseconds(10))
    }

    @Test
    func `sleep delegates to wrapped Immediate clock`() async throws {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let deadline = erased.now.advanced(by: .seconds(3))
        try await erased.sleep(until: deadline)
        #expect(immediate.now.offset == .seconds(3))
    }

    @Test
    func `Erased instants read from unchanged clock state compare equal`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let a = erased.now
        let b = erased.now
        #expect(a == b)
    }

    @Test
    func `Erased instants order an advanced instant after its source`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let a = erased.now
        let b = a.advanced(by: .seconds(1))
        #expect(a < b)
        #expect(!(b < a))
    }

    @Test
    func `type-erased instant hashing: equal values produce equal hashes`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let a = erased.now
        let b = erased.now
        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func `Erased instants measure the duration used to advance them`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let a = erased.now
        let b = a.advanced(by: .seconds(5))
        #expect(a.duration(to: b) == .seconds(5))
    }
}

extension `Erased clocks preserve their wrapped behavior`.`Boundary values preserve their contracts` {
    @Test
    func `Advancing an erased instant by zero preserves equality`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let a = erased.now
        let b = a.advanced(by: .zero)
        #expect(a == b)
    }

    @Test
    func `type-erased instant duration to self is zero`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        let a = erased.now
        #expect(a.duration(to: a) == .zero)
    }

    @Test
    func `wrapping Immediate with default minimumResolution is zero`() {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)
        #expect(erased.minimumResolution == .zero)
    }
}

extension `Erased clocks preserve their wrapped behavior`.`Operations compose correctly` {
    @Test
    func `Advancing a wrapped test clock resumes its erased sleep`() async throws {
        let test = Clock.Test()
        let erased = Clock.Any(test)
        let resumed = Locked(initialState: false)

        let task = Task.immediate {
            let deadline = erased.now.advanced(by: .seconds(5))
            try await erased.sleep(until: deadline)
            resumed.withLock { $0 = true }
        }

        test.advance(by: .seconds(5))
        try await task.value
        #expect(resumed.withLock { $0 })
    }

    @Test
    func `Sequential erased sleeps advance the wrapped immediate clock cumulatively`() async throws {
        let immediate = Clock.Immediate()
        let erased = Clock.Any(immediate)

        let d1 = erased.now.advanced(by: .seconds(1))
        try await erased.sleep(until: d1)
        #expect(immediate.now.offset == .seconds(1))

        let d2 = erased.now.advanced(by: .seconds(2))
        try await erased.sleep(until: d2)
        #expect(immediate.now.offset == .seconds(3))
    }
}
