// expected-error: global function 'requireInstant' requires that 'Coordinate<1, Duration>' conform to 'InstantProtocol'
import Coordinate
func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Coordinate<1, Swift.Duration>(rawValue: .zero))
