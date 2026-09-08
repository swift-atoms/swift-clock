// expected-error: cannot assign value of type
import Clock
import Tagged
import Time

let invalid: Tagged<Clock.Continuous, Time.Coordinate> =
    Clock.Suspending.Instant.reference
