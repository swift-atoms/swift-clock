import Clock
import Testing

private final class OpaquePayload { var value = 0 }
@Test func `Deadline representation does not require protocols`() {
    let payload = OpaquePayload()
    let deadline = Clock.Deadline(payload)
    #expect(deadline.instant === payload)
    #expect(Clock.Deadline<OpaquePayload>.never.instant == nil)
}
@Test func `Ordering and expiration need only comparable`() {
    let first = Clock.Deadline(1)
    let last = Clock.Deadline(2)
    #expect([.never, last, first].sorted() == [first, last, .never])
    #expect(!last.hasExpired(at: 1))
    #expect(last.hasExpired(at: 2))
    #expect(!Clock.Deadline<Int>.never.hasExpired(at: .max))
    #expect(Set([first, first, last]).count == 2)
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

@Test func `Protocol deadline operations retain their arithmetic contract`() {
    let origin = TickInstant(tick: 7)
    let past = Clock.Deadline<TickInstant>.after(.init(count: -1), from: origin)
    let future = Clock.Deadline<TickInstant>.after(.init(count: 3), from: origin)
    let never = Clock.Deadline<TickInstant>.never
    #expect(past.instant == TickInstant(tick: 6))
    #expect(past.hasExpired(at: origin))
    #expect(past.remaining(at: origin) == .zero)
    #expect(future.remaining(at: TickInstant(tick: 10)) == .zero)
    #expect(future.remaining(at: TickInstant(tick: 11)) == .zero)
    #expect(never.remaining(at: origin) == nil)
    #expect(never.instant == nil)
    #expect(!never.hasExpired(at: origin))
}
@Test func `Expired protocol deadlines do not compute an overflowing difference`() {
    let earliest = TickInstant(tick: .min)
    let latest = TickInstant(tick: .max)
    #expect(Clock.Deadline(earliest).remaining(at: latest) == .zero)
}
