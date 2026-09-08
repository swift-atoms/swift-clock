// expected-error: has no member 'secondsSinceUnixEpoch'
import Clock

let invalid = Clock.Continuous.Instant.reference.secondsSinceUnixEpoch
