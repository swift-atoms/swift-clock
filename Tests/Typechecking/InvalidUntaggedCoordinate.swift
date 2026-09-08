// expected-error: cannot convert value of type
import Clock
import Time

let invalid: Clock.Continuous.Instant = Time.Coordinate.reference
