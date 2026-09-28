// expected-error: operator function '*' requires the types 'Tagged<Time, Coordinate<1, Duration>>.Underlying' (aka 'Coordinate<1, Duration>') and 'Cardinal' be equivalent
import Time

let invalid = Time.Coordinate.reference * 2
