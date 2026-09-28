// expected-error: value of type 'Clock.Continuous' has no member 'now'
import Clock

let invalid = Clock.Continuous().now
