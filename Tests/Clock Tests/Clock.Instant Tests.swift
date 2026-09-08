import Clock
import Tagged
import Testing
import Time

private final class LocalDomain { var state = 0 }
private struct NoncopyableDomain: ~Copyable {}
private func sendable<T: Sendable>(_ value: T) -> T { value }

@Test func `Clock instant is exactly the tagged coordinate`() {
    let coordinate = Time.Coordinate(offset: .seconds(5))
    let tagged = Tagged<Clock.Continuous, Time.Coordinate>(_unchecked: coordinate)
    let instant: Clock.Continuous.Instant = tagged
    let sameTagged: Tagged<Clock.Continuous, Time.Instant> = instant
    #expect(instant.underlying == coordinate)
    #expect(sameTagged == tagged)
}
@Test func `Phantom domain does not constrain ownership or sendability`() {
    let local = sendable(Clock.Instant<LocalDomain>(offset: .seconds(-3)))
    let noncopyable = sendable(Clock.Instant<NoncopyableDomain>.reference)
    let copy = noncopyable
    #expect(local.offset == .seconds(-3))
    #expect(noncopyable == copy)
}
@Test func `Clock domains share representation not identity`() {
    let continuous = Clock.Continuous.Instant.reference
    let suspending = Clock.Suspending.Instant.reference
    #expect(continuous.underlying == suspending.underlying)
}
