// expected-error: cannot assign value of type 'Tagged<Clock.Suspending, Tagged<Time, Coordinate<1, Duration>>>' to type 'Tagged<Clock.Continuous, Time.Coordinate>' (aka 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>')
import Clock
import Tagged
import Time

let invalid: Tagged<Clock.Continuous, Time.Coordinate> =
    Clock.Suspending.Instant.reference
