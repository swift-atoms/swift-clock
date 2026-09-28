// expected-error: cannot convert value of type 'Time.Instant' to specified type 'Clock.Continuous.Instant'
import Clock
import Time

let invalid: Clock.Continuous.Instant = Time.Instant(secondsSinceUnixEpoch: 0)
