// expected-error: global function 'requireRuntime' requires that 'Clock.Continuous' conform to 'Clock'
import Clock

func requireRuntime<C: Swift.Clock>(_ clock: C) {}
func invalid() { requireRuntime(Clock.Continuous()) }
