import Clock
import Testing

// A consumer supplies clock behavior using only the atom's public instant type.
// Conformance belongs to that consumer, not to the atom's domain markers.
private struct SuppliedClock: Swift.Clock {
    typealias Instant = Clock.Continuous.Instant
    var now: Instant
    var minimumResolution: Swift.Duration { .nanoseconds(100) }

    func sleep(until deadline: Instant, tolerance: Swift.Duration?) async throws {
        precondition(deadline <= now)
    }
}

private func read<C: Swift.Clock>(_ clock: C) -> C.Instant { clock.now }

@Test
func `a consumer can supply Swift Clock behavior over the domain instant`() async throws {
    let instant = Clock.Continuous.Instant(offset: .seconds(10))
    let clock = SuppliedClock(now: instant)

    #expect(read(clock) == instant)
    #expect(clock.minimumResolution == .nanoseconds(100))
    try await clock.sleep(until: instant, tolerance: nil)
}
