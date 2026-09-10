import Clock

let deadline = Clock.Continuous.Deadline.never
let invalid = deadline.hasExpired(at: Clock.Suspending.Instant.reference)
