// expected-error: cannot convert value of type 'Duration' to specified type 'Clock.Continuous.Instant' (aka 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>')
import Clock

let invalid: Clock.Continuous.Instant = Swift.Duration.seconds(1)
