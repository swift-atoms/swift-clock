extension Tagged where Underlying == Clock.Nanoseconds {

    @inlinable
    public var nanoseconds: UInt64 { underlying.rawValue }

    @inlinable
    public init(nanoseconds: UInt64) {
        self.init(Clock.Nanoseconds(nanoseconds))
    }
}
