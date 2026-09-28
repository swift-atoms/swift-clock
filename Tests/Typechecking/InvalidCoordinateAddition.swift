// expected-error: binary operator '+' cannot be applied to two 'Tagged<Time, Coordinate<1, Duration>>' operands
import Time

let invalid = Time.Coordinate.reference + Time.Coordinate.reference
