// expected-error: (aka 'Time.Coordinate') and 'Cardinal' be equivalent
import Clock

let instant = Clock.Continuous.Instant.reference
let invalid = instant * 2
