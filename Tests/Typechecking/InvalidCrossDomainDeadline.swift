// expected-error: cannot convert value of type 'Tagged<Clock.Suspending, Tagged<Time, Coordinate<1, Duration>>>' to expected argument type 'Clock.Continuous.Instant' (aka 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>')
import Clock

let deadline = Clock.Continuous.Deadline.never
let invalid = deadline.hasExpired(at: Clock.Suspending.Instant.reference)
