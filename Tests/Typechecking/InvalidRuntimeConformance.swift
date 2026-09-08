// expected-error: conform to 'Clock'
import Clock

func requireRuntime<C: Swift.Clock>(_ clock: C) {}
func invalid() { requireRuntime(Clock.Continuous()) }
