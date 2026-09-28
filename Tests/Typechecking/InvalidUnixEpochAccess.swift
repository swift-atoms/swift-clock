// expected-error: value of type 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>' has no member 'secondsSinceUnixEpoch'
import Clock

let invalid = Clock.Continuous.Instant.reference.secondsSinceUnixEpoch
