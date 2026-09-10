import Clock
func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Clock.Continuous.Instant.reference)
