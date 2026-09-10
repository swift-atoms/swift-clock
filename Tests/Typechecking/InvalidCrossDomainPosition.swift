import Clock
import Tagged
import Time

let invalid: Tagged<Clock.Continuous, Time.Coordinate> =
    Clock.Suspending.Instant.reference
