// expected-error: 'Tagged<Time, Coordinate<1, Duration>>
import Time

let invalid = Time.Coordinate.reference * 2
