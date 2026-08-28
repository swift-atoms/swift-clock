import Clock
import Tagged
import Testing

private enum TestClock {}

private func advance<Tag, Instant>(
    _ instant: Tagged::Tagged<Tag, Instant>,
    by duration: Swift.Duration
) -> Tagged::Tagged<Tag, Instant>
where
    Instant: InstantProtocol,
    Instant.Duration == Swift.Duration
{
    instant.advanced(by: duration)
}

@Suite
struct `Tagged InstantProtocol Tests` {

    @Test
    func `tagged instant requires only InstantProtocol`() {
        let start = Tagged::Tagged<TestClock, Clock.Offset>(
            _unchecked: Clock.Offset(.seconds(2))
        )
        let end = advance(start, by: .seconds(3))

        #expect(start.duration(to: end) == .seconds(3))
        #expect(end.underlying == Clock.Offset(.seconds(5)))
    }
}
