import Clock

let first = Clock.Continuous.Instant.reference
let second = Clock.Continuous.Instant.reference
let invalid = first + second
