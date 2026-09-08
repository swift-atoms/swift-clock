// expected-error: conform to 'InstantProtocol'
import Coordinate
func requireInstant<I: Swift.InstantProtocol>(_ instant: I) {}
requireInstant(Coordinate<1, Swift.Duration>(rawValue: .zero))
