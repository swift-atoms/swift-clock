import Clock
import Tagged
import Testing

extension Clock.Immediate {
    @Suite
    struct `Clock operations preserve their contracts` {
        @Suite struct `Values preserve their representation` {}
        @Suite struct `Boundary values preserve their contracts` {}
        @Suite struct `Operations compose correctly` {}
        @Suite(.serialized) struct `Operations meet performance expectations` {}
    }
}

extension Clock.Immediate.`Clock operations preserve their contracts`.`Values preserve their representation` {
    @Test
    func `init default now is zero offset`() {
        let clock = Clock.Immediate()
        #expect(clock.now.offset == .zero)
    }

    @Test
    func `Clock construction preserves the supplied current instant`() {
        let instant = Clock.Immediate.Instant(offset: .seconds(5))
        let clock = Clock.Immediate(now: instant)
        #expect(clock.now.offset == .seconds(5))
    }

    @Test
    func `minimumResolution defaults to zero`() {
        let clock = Clock.Immediate()
        #expect(clock.minimumResolution == .zero)
    }

    @Test
    func `Assigning the minimum resolution retains the supplied duration`() {
        let clock = Clock.Immediate()
        clock.minimumResolution = .milliseconds(10)
        #expect(clock.minimumResolution == .milliseconds(10))
    }

    @Test
    func `sleep advances now to deadline`() async throws {
        let clock = Clock.Immediate()
        let deadline = Clock.Immediate.Instant(offset: .seconds(3))
        try await clock.sleep(until: deadline)
        #expect(clock.now == deadline)
    }

    @Test
    func `Advancing an instant adds its supplied duration to the coordinate`() {
        let instant = Clock.Immediate.Instant(offset: .seconds(1))
        let advanced = instant.advanced(by: .seconds(2))
        #expect(advanced.offset == .seconds(3))
    }

    @Test
    func `Instants measure the duration between their coordinates`() {
        let a = Clock.Immediate.Instant(offset: .seconds(1))
        let b = Clock.Immediate.Instant(offset: .seconds(4))
        #expect(a.duration(to: b) == .seconds(3))
    }

    @Test
    func `Instants compare in coordinate order`() {
        let a = Clock.Immediate.Instant(offset: .seconds(1))
        let b = Clock.Immediate.Instant(offset: .seconds(2))
        #expect(a < b)
        #expect(!(b < a))
    }

    @Test
    func `Instants with equal coordinates compare equal`() {
        let a = Clock.Immediate.Instant(offset: .seconds(5))
        let b = Clock.Immediate.Instant(offset: .seconds(5))
        #expect(a == b)
    }

    @Test
    func `Instant hashing: equal values produce equal hashes`() {
        let a = Clock.Immediate.Instant(offset: .seconds(5))
        let b = Clock.Immediate.Instant(offset: .seconds(5))
        #expect(a.hashValue == b.hashValue)
    }
}

extension Clock.Immediate.`Clock operations preserve their contracts`.`Boundary values preserve their contracts` {
    @Test
    func `sleep throws when task is cancelled`() async {
        let clock = Clock.Immediate()
        let task = Task {
            try await clock.sleep(until: .init(offset: .seconds(1)))
        }
        task.cancel()
        let result = await task.result
        #expect(throws: CancellationError.self) { try result.get() }
    }

    @Test
    func `Advancing an instant by zero preserves equality`() {
        let instant = Clock.Immediate.Instant(offset: .seconds(1))
        let advanced = instant.advanced(by: .zero)
        #expect(advanced == instant)
    }

    @Test
    func `Instant duration to self is zero`() {
        let instant = Clock.Immediate.Instant(offset: .seconds(3))
        #expect(instant.duration(to: instant) == .zero)
    }

    @Test
    func `Instant default offset is zero`() {
        let instant = Clock.Immediate.Instant()
        #expect(instant.offset == .zero)
    }

    @Test
    func `Advancing an instant by a negative duration decreases its coordinate`() {
        let instant = Clock.Immediate.Instant(offset: .seconds(5))
        let advanced = instant.advanced(by: .seconds(-2))
        #expect(advanced.offset == .seconds(3))
    }
}

extension Clock.Immediate.`Clock operations preserve their contracts`.`Operations compose correctly` {
    @Test
    func `sequential sleeps advance time cumulatively`() async throws {
        let clock = Clock.Immediate()
        try await clock.sleep(until: .init(offset: .seconds(1)))
        #expect(clock.now.offset == .seconds(1))

        try await clock.sleep(until: .init(offset: .seconds(5)))
        #expect(clock.now.offset == .seconds(5))
    }
}
