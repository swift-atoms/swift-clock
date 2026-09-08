// expected-error: cannot convert value of type
import Clock

let continuous = Clock.Continuous.Instant.reference
let suspending = Clock.Suspending.Instant.reference
let invalid = continuous.duration(to: suspending)
