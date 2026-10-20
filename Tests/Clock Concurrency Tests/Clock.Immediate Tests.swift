import Clock_Concurrency
import Testing
import Time

@Suite
struct `Clock.Immediate` {
    @Test
    func `sleeping until a deadline adopts that deadline as now`() async throws {
        let clock = Clock.Immediate()
        let deadline = clock.now.advanced(by: .seconds(5))

        try await clock.sleep(until: deadline)

        #expect(clock.now == deadline)
    }

    @Test
    func `a fresh clock reports the instant it was created with`() {
        let start = Clock.Immediate.Instant(Time.Instant(secondsSinceUnixEpoch: 0)).advanced(by: .nanoseconds(0)).advanced(by: .seconds(3))
        let clock = Clock.Immediate(now: start)

        #expect(clock.now == start)
    }

    @Test
    func `sleeping for an earlier deadline never moves now backwards`() async throws {
        let clock = Clock.Immediate(
            now: Clock.Immediate.Instant(Time.Instant(secondsSinceUnixEpoch: 0)).advanced(by: .nanoseconds(10))
        )

        try await clock.sleep(
            until: Clock.Immediate.Instant(Time.Instant(secondsSinceUnixEpoch: 0)).advanced(by: .nanoseconds(5))
        )

        #expect(clock.now == Clock.Immediate.Instant(Time.Instant(secondsSinceUnixEpoch: 0)).advanced(by: .nanoseconds(10)))
    }
}
