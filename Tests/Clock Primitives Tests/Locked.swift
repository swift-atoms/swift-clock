import Synchronization

final class Locked<Value: Sendable>: Sendable {
    private let mutex: Mutex<Value>

    init(initialState: Value) {
        self.mutex = Mutex(initialState)
    }

    func withLock<Result>(_ body: (inout sending Value) -> sending Result) -> sending Result {
        mutex.withLock(body)
    }
}
