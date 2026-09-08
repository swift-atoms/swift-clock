import Clock
import Testing

@Suite
struct `Clock deadlines distinguish finite expiration from never` {
    @Test
    func `a finite deadline expires at its instant and has no negative remaining time`() {
        let origin = Clock.Continuous.Instant.reference
        let deadline = Clock.Continuous.Deadline.after(.seconds(3), from: origin)

        #expect(deadline == .at(origin + .seconds(3)))
        #expect(deadline.instant == origin + .seconds(3))
        #expect(!deadline.hasExpired(at: origin))
        #expect(deadline.remaining(at: origin) == .seconds(3))
        #expect(deadline.hasExpired(at: origin + .seconds(3)))
        #expect(deadline.remaining(at: origin + .seconds(3)) == .zero)
        #expect(deadline.hasExpired(at: origin + .seconds(4)))
        #expect(deadline.remaining(at: origin + .seconds(4)) == .zero)
    }

    @Test
    func `a negative delay produces an expired finite deadline before the reference`() {
        let origin = Clock.Suspending.Instant.reference
        let deadline = Clock.Suspending.Deadline.after(.seconds(-1), from: origin)

        #expect(deadline.instant?.offset == .seconds(-1))
        #expect(deadline.hasExpired(at: origin))
        #expect(deadline.remaining(at: origin) == .zero)
    }

    @Test
    func `a subnanosecond delay is preserved instead of expiring early`() {
        let origin = Clock.Continuous.Instant.reference
        let duration = Swift.Duration(attoseconds: 1)
        let deadline = Clock.Continuous.Deadline.after(duration, from: origin)

        #expect(!deadline.hasExpired(at: origin))
        #expect(deadline.remaining(at: origin) == duration)
        #expect(deadline.hasExpired(at: origin + duration))
    }

    @Test(arguments: [Int128.min, -1, 0, 1, Int128.max])
    func `never has no finite instant or remaining duration and never expires`(
        attoseconds: Int128
    ) {
        let now = Clock.Continuous.Instant(offset: .init(attoseconds: attoseconds))
        let never = Clock.Continuous.Deadline.never

        #expect(never.instant == nil)
        #expect(never.remaining(at: now) == nil)
        #expect(!never.hasExpired(at: now))
    }

    @Test
    func `the largest finite coordinate remains distinct from never`() {
        let origin = Clock.Continuous.Instant.reference
        let duration = Swift.Duration(attoseconds: .max)
        let maximum = origin + duration
        let finite = Clock.Continuous.Deadline.after(duration, from: origin)
        let never = Clock.Continuous.Deadline.never

        #expect(finite != never)
        #expect(finite.instant == maximum)
        #expect(finite.remaining(at: origin) == duration)
        #expect(finite.hasExpired(at: maximum))
        #expect(!never.hasExpired(at: maximum))
        #expect(Set([finite, never]).count == 2)
    }

    @Test
    func `expired deadlines do not subtract unrepresentably distant coordinates`() {
        let minimum = Clock.Continuous.Instant(offset: .init(attoseconds: .min))
        let maximum = Clock.Continuous.Instant(offset: .init(attoseconds: .max))

        #expect(Clock.Continuous.Deadline(minimum).remaining(at: maximum) == .zero)
    }

    @Test
    func `all finite deadlines precede never and preserve instant ordering`() {
        let origin = Clock.Suspending.Instant.reference
        let early = Clock.Suspending.Deadline(origin - .seconds(1))
        let late = Clock.Suspending.Deadline(origin + .seconds(1))
        let never = Clock.Suspending.Deadline.never

        #expect([never, late, early].sorted() == [early, late, never])
        #expect(!(never < never))
        #expect(!(early < early))
    }
}

// An independent instant and duration pair exercises the generic deadline
// contract without relying on Swift.Duration or Clock.Instant.
private struct TickDuration: Swift.DurationProtocol, Hashable {
    let count: Int
    static let zero = Self(count: 0)
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.count < rhs.count }
    static func + (lhs: Self, rhs: Self) -> Self { Self(count: lhs.count + rhs.count) }
    static func - (lhs: Self, rhs: Self) -> Self { Self(count: lhs.count - rhs.count) }
    static func * (lhs: Self, rhs: Int) -> Self { Self(count: lhs.count * rhs) }
    static func / (lhs: Self, rhs: Int) -> Self { Self(count: lhs.count / rhs) }
    static func / (lhs: Self, rhs: Self) -> Double { Double(lhs.count) / Double(rhs.count) }
    static func *= (lhs: inout Self, rhs: Int) { lhs = lhs * rhs }
    static func /= (lhs: inout Self, rhs: Int) { lhs = lhs / rhs }
}

private struct TickInstant: Swift.InstantProtocol {
    let tick: Int
    func advanced(by duration: TickDuration) -> Self { Self(tick: tick + duration.count) }
    func duration(to other: Self) -> TickDuration { TickDuration(count: other.tick - tick) }
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.tick < rhs.tick }
}

@Test
func `deadline operations reuse any instant and its associated duration`() {
    let origin = TickInstant(tick: 7)
    let deadline = Clock.Deadline<TickInstant>.after(TickDuration(count: 3), from: origin)

    #expect(deadline.instant == TickInstant(tick: 10))
    #expect(deadline.remaining(at: origin) == TickDuration(count: 3))
    #expect(deadline.hasExpired(at: TickInstant(tick: 10)))
    #expect(deadline < .never)
}
