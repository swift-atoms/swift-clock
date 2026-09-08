import Clock
import Tagged
import Testing

extension Clock.Continuous {
    @Suite
    struct `Clock operations preserve their contracts` {
        @Suite struct `Values preserve their representation` {}
        @Suite struct `Boundary values preserve their contracts` {}
        @Suite struct `Operations compose correctly` {}
        @Suite(.serialized) struct `Operations meet performance expectations` {}
    }
}

extension Clock.Continuous.`Clock operations preserve their contracts`.`Values preserve their representation` {
    @Test
    func `init creates instance`() {
        let clock = Clock.Continuous()
        #expect(clock.minimumResolution == .nanoseconds(1))
    }

    @Test
    func `Instant init stores nanoseconds`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 42)
        #expect(instant.nanoseconds == 42)
    }

    @Test
    func `Advancing an instant by a positive duration increases its coordinate`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 1_000_000_000)
        let advanced = instant.advanced(by: .seconds(2))
        #expect(advanced.nanoseconds == 3_000_000_000)
    }

    @Test
    func `Advancing an instant by a negative duration decreases its coordinate`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 3_000_000_000)
        let advanced = instant.advanced(by: .seconds(-1))
        #expect(advanced.nanoseconds == 2_000_000_000)
    }

    @Test
    func `Instant duration to later instant is positive`() {
        let a = Clock.Continuous.Instant(nanoseconds: 1_000_000_000)
        let b = Clock.Continuous.Instant(nanoseconds: 3_000_000_000)
        #expect(a.duration(to: b) == .seconds(2))
    }

    @Test
    func `Instant duration to earlier instant is negative`() {
        let a = Clock.Continuous.Instant(nanoseconds: 3_000_000_000)
        let b = Clock.Continuous.Instant(nanoseconds: 1_000_000_000)
        #expect(a.duration(to: b) == .seconds(-2))
    }

    @Test
    func `Instants compare in coordinate order`() {
        let a = Clock.Continuous.Instant(nanoseconds: 100)
        let b = Clock.Continuous.Instant(nanoseconds: 200)
        #expect(a < b)
        #expect(!(b < a))
        #expect(!(a < a))
    }

    @Test
    func `Instants with equal coordinates compare equal`() {
        let a = Clock.Continuous.Instant(nanoseconds: 42)
        let b = Clock.Continuous.Instant(nanoseconds: 42)
        let c = Clock.Continuous.Instant(nanoseconds: 43)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Instant hashing: equal values produce equal hashes`() {
        let a = Clock.Continuous.Instant(nanoseconds: 99)
        let b = Clock.Continuous.Instant(nanoseconds: 99)
        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func `Advancing an instant preserves a fractional second duration`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 0)
        let advanced = instant.advanced(by: .milliseconds(500))
        #expect(advanced.nanoseconds == 500_000_000)
    }
}

extension Clock.Continuous.`Clock operations preserve their contracts`.`Boundary values preserve their contracts` {
    @Test
    func `Advancing an instant by zero duration preserves its value`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 42)
        let advanced = instant.advanced(by: .zero)
        #expect(advanced == instant)
    }

    @Test
    func `Instant duration to self is zero`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 42)
        #expect(instant.duration(to: instant) == .zero)
    }

    @Test
    func `An instant constructed from zero nanoseconds stores zero`() {
        let instant = Clock.Continuous.Instant(nanoseconds: 0)
        #expect(instant.nanoseconds == 0)
    }

    @Test
    func `Advancing a maximum nanosecond instant by one nanosecond wraps to zero`() {
        let instant = Clock.Continuous.Instant(nanoseconds: .max)
        let advanced = instant.advanced(by: .nanoseconds(1))
        #expect(advanced.nanoseconds == 0)
    }

    @Test
    func `Measuring an advanced instant recovers its displacement`() {
        let start = Clock.Continuous.Instant(nanoseconds: 1000)
        let duration: Duration = .milliseconds(250)
        let end = start.advanced(by: duration)
        #expect(start.duration(to: end) == duration)
    }
}
