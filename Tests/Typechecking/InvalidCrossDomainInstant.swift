// expected-error: cannot assign value of type
import Clock
let suspending = Clock.Suspending.Instant.reference
let invalid: Clock.Continuous.Instant = suspending
