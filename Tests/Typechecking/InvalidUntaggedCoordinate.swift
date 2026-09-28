// expected-error: cannot assign value of type 'Tagged<Time, Coordinate<1, Duration>>' to type 'Clock.Continuous.Instant' (aka 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>')
import Clock
import Time

let invalid: Clock.Continuous.Instant = Time.Coordinate.reference
