// expected-error: operator function '*' requires that 'Time.Coordinate' conform to '_CarrierProtocol'
import Time

let invalid = Time.Coordinate.reference * 2
