// expected-error: global function 'requireInstant' requires that 'Coordinate<1, Duration>' conform to 'InstantProtocol'
import Time

func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Time.Coordinate.reference)
