// expected-error: binary operator '+' cannot be applied to two 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>' operands
import Clock

let first = Clock.Continuous.Instant.reference
let second = Clock.Continuous.Instant.reference
let invalid = first + second
