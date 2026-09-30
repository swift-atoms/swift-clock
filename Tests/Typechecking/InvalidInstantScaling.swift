// expected-error: 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>
import Clock

let instant = Clock.Continuous.Instant.reference
let invalid = instant * 2
