// expected-error: cannot convert value of type
import Clock

let invalid: Clock.Continuous.Instant = Swift.Duration.seconds(1)
