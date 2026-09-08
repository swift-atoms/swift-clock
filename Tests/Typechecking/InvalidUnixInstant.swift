// expected-error: cannot convert value of type
import Clock
import Time

let invalid: Clock.Continuous.Instant = Instant(secondsSinceUnixEpoch: 0)
