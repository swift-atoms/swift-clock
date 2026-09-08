import Clock
import Testing
import Tagged
import Time

private final class LocalDomain {
    var state = 0
}

private struct NoncopyableDomain: ~Copyable {}

private func sendable<Value: Sendable>(_ value: Value) -> Value { value }

private func translated<I: Swift.InstantProtocol>(
    _ instant: I,
    by duration: I.Duration
) -> I {
    instant.advanced(by: duration)
}

@Suite
struct `Clock instants preserve their domain and native duration semantics` {
    @Test
    func `clock instants are tagged coordinates not wrappers around tagged values`() {
        let coordinate = Time.Coordinate(offset: .seconds(5))
        let tagged = Tagged<Clock.Continuous, Time.Coordinate>(_unchecked: coordinate)
        let instant: Clock.Continuous.Instant = tagged
        let sameTagged: Tagged<Clock.Continuous, Time.Coordinate> = instant

        #expect(instant.underlying == coordinate)
        #expect(sameTagged == tagged)
        #expect(instant.advanced(by: .seconds(2)).underlying == coordinate + .seconds(2))
    }

    @Test(arguments: [
        Int128(-3_000_000_000_000_000_000), -1_000_000_000, -1, 0,
        1, 999_999_999, 1_000_000_000, 3_000_000_000_000_000_000,
    ])
    func `translation preserves signed attoseconds and recovers the displacement`(
        attoseconds: Int128
    ) {
        let start = Clock.Continuous.Instant(offset: .seconds(5))
        let duration = Swift.Duration(attoseconds: attoseconds)
        let end = translated(start, by: duration)

        #expect(end.offset == start.offset + duration)
        #expect(start.duration(to: end) == duration)
        #expect(end - start == duration)
        #expect(end - duration == start)
        #expect(start + duration == end)
        #expect(duration + start == end)
        #expect((start < end) == (duration > .zero))
    }

    @Test
    func `continuous and suspending instants share the generic model`() {
        let continuous: Clock.Instant<Clock.Continuous> =
            Clock.Continuous.Instant.reference
        let suspending: Clock.Instant<Clock.Suspending> =
            Clock.Suspending.Instant.reference
        let duration: Clock.Continuous.Duration = .seconds(3)
        let sameDuration: Clock.Suspending.Duration = duration

        #expect(continuous.advanced(by: duration).offset == duration)
        #expect(suspending.advanced(by: sameDuration).offset == duration)
        #expect(continuous.offset == suspending.offset)
    }

    @Test(arguments: [Int128.min, Int128.min + 1, Int128.max - 1, Int128.max])
    func `reference translation preserves the entire native coordinate range`(
        attoseconds: Int128
    ) {
        let duration = Swift.Duration(attoseconds: attoseconds)
        let origin = Clock.Continuous.Instant.reference
        let instant = origin + duration

        #expect(instant.offset.attoseconds == attoseconds)
        #expect(origin.duration(to: instant) == duration)
        #expect(instant - duration == origin)
        #expect(instant.duration(to: instant) == .zero)
    }

    @Test
    func `subtracting the minimum duration does not negate it first`() {
        let minimum = Swift.Duration(attoseconds: .min)
        var instant = Clock.Suspending.Instant(offset: minimum)

        instant -= minimum

        #expect(instant == .reference)
    }

    @Test
    func `arithmetic crosses the reference without unsigned wrapping`() {
        var instant = Clock.Suspending.Instant.reference
        instant -= .seconds(1)
        #expect(instant.offset == .seconds(-1))
        instant += .seconds(2)
        #expect(instant.offset == .seconds(1))
    }

    @Test
    func `equal instants have consistent set membership`() {
        let origin = Clock.Continuous.Instant.reference
        let first = origin + .seconds(2)
        let second = origin + .seconds(1) + .seconds(1)

        #expect(Set([first, second, origin]).count == 2)
    }

    @Test
    func `a phantom domain imposes no ownership or sendability requirement`() {
        let local = sendable(Clock.Instant<LocalDomain>(offset: .seconds(-3)))
        let noncopyable = sendable(Clock.Instant<NoncopyableDomain>.reference)
        let copy = noncopyable

        #expect(local + .seconds(3) == .reference)
        #expect(noncopyable == copy)
    }
}
