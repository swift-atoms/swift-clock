import Clock
import Testing

private enum Session {}

@Test func `Coordinate deadlines measure the time left from their offset`() {
    let origin = Clock.Instant<Session>(offset: .seconds(7))
    let deadline = Clock.Deadline<Clock.Instant<Session>>.after(.seconds(3), from: origin)
    #expect(deadline.instant == Clock.Instant<Session>(offset: .seconds(10)))
    #expect(deadline.remaining(at: origin) == .seconds(3))
    #expect(deadline.hasExpired(at: Clock.Instant<Session>(offset: .seconds(10))))
}

@Test func `Coordinate deadlines clamp elapsed time at zero`() {
    let origin = Clock.Instant<Session>(offset: .seconds(7))
    let past = Clock.Deadline<Clock.Instant<Session>>.after(.seconds(-1), from: origin)
    let never = Clock.Deadline<Clock.Instant<Session>>.never
    #expect(past.remaining(at: origin) == .zero)
    #expect(past.remaining(at: Clock.Instant<Session>(offset: .seconds(6))) == .zero)
    #expect(never.remaining(at: origin) == nil)
}
