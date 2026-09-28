// expected-error: operator function '*' requires the types 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>.Underlying' (aka 'Tagged<Time, Coordinate<1, Duration>>') and 'Cardinal' be equivalent
import Clock

let instant = Clock.Continuous.Instant.reference
let invalid = instant * 2
