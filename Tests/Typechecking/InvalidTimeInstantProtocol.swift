import Time

func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Time.Instant.reference)
