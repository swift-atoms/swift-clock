# swift-clock

Use the `Clock` module to name points and deadlines on one clock's timeline without reading that clock: `Clock.Instant<Domain>` is an offset from the domain's reference point, and `Clock.Deadline<Instant>` is such an instant or `.never`; `Clock.Continuous` and `Clock.Suspending` are domains only and cannot tell the time. Use the `Clock Concurrency` module when code has to sleep and a test has to control when it wakes: write that code against `Clock.Nonsending`, pass `Swift.ContinuousClock` or `Swift.SuspendingClock` in production, `Clock.Test` in a test that steps time, `Clock.Immediate` in a test that should not wait at all, and `Clock.Unimplemented` where no sleep is expected; `Clock.Any` erases any of them. For a wall-clock instant measured from the Unix epoch, use `Time.Instant` from swift-time instead.

## Laws

- Instants of different domains share their representation but never mix: assigning, comparing or measuring a `Clock.Suspending.Instant` against a `Clock.Continuous.Deadline` does not compile, and neither does adding two instants, scaling one, or reading one as a Unix time.
- `Clock.Deadline` orders every `.at` before `.never`. `.never` never expires and has no remaining time (`nil`). A deadline at `d` has expired at every instant `>= d`, and its remaining time is zero from then on; computing it never subtracts a later instant from an earlier one, so it cannot overflow.
- `Clock.Test` moves only when `advance` or `run` moves it, and never backwards: advancing to an earlier instant or by a negative duration stops the program. Advancing wakes each sleep due by the target, earliest deadline first and, among equal deadlines, in the order the sleeps began; the clock reads the sleep's deadline while it wakes. Each sleeper is resumed on the actor it slept from, and the advance continues only once that sleeper has slept again or finished, so every effect of the wake-up has landed when `advance` returns. `run` advances until no sleep is pending, including sleeps that woken work starts, and does not return while work sleeps forever. A sleep whose deadline is not after `now` returns at once.
- A `Clock.Test` sleep from a nonisolated context stops the program, since it has no actor to resume on deterministically.
- Cancellation: a `Clock.Test` sleep that is cancelled before or while it waits is withdrawn without moving the clock and throws as `Task.checkCancellation()` does. A `Clock.Immediate` sleep checks cancellation before it does anything.
- `Clock.Immediate` sleeps return at once and move `now` to the deadline, unless the deadline is earlier: `now` never moves backwards.
- `Clock.Test.checkSuspension()` throws while any sleep is pending.
- Any sleep on `Clock.Unimplemented` stops the program.
- `Clock.Any` passes the caller's actor through to the clock it wraps. Comparing, measuring or sleeping with an instant of one wrapped clock type against a `Clock.Any` wrapping another stops the program.
- `Clock.Continuous.Deadline.Next` keeps a deadline to whole nanoseconds, truncating the rest and clamping an offset before the reference point to it. Its stores and reads are atomic, with release and acquire ordering.
- Under Embedded Swift, `Clock Concurrency` contributes nothing beyond re-exporting `Clock`.
