// expected-error: global function 'requireInstant' requires that 'Coordinate<1, Duration>' conform to 'InstantProtocol'
import Clock
func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Clock.Continuous.Instant.reference)
