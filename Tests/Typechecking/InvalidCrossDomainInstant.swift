// expected-error: cannot assign value of type 'Tagged<Clock.Suspending, Tagged<Time, Coordinate<1, Duration>>>' to type 'Clock.Continuous.Instant' (aka 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>')
import Clock
let suspending = Clock.Suspending.Instant.reference
let invalid: Clock.Continuous.Instant = suspending
