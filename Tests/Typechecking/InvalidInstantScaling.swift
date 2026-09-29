// expected-error: binary operator '*' cannot be applied to operands of type 'Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>' and 'Ratio<Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>.Domain, Tagged<Clock.Continuous, Tagged<Time, Coordinate<1, Duration>>>.Domain>' (aka 'Ratio<Clock.Continuous, Clock.Continuous>')
import Clock

let instant = Clock.Continuous.Instant.reference
let invalid = instant * 2
