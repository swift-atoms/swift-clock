public import Tagged

extension Tagged where Underlying == Clock.Offset {

    @inlinable
    public var offset: Swift.Duration { underlying.rawValue }

    @inlinable
    public init(offset: Swift.Duration = .zero) {
        self.init(_unchecked: Clock.Offset(offset))
    }
}
