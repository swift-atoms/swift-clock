public import Tagged
public import Time

extension Tagged where Tag: ~Copyable & ~Escapable, Underlying == Time.Instant {
    public init(offset: Swift.Duration) { self.init(_unchecked: Underlying(offset: offset)) }
    public var offset: Swift.Duration { underlying.offset }

    public static var reference: Self { Self(offset: .zero) }
}
