// expected-error: binary operator '*' cannot be applied to operands of type 'Tagged<Time, Coordinate<1, Duration>>' and 'Ratio<Tagged<Time, Coordinate<1, Duration>>.Domain, Tagged<Time, Coordinate<1, Duration>>.Domain>' (aka 'Ratio<Time, Time>')
import Time

let invalid = Time.Coordinate.reference * 2
