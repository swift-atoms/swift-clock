// expected-error: conform to 'InstantProtocol'
import Time
func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Time.Coordinate.reference)
