@_exported public import Tagged
@_exported public import Time

extension Clock {

    public typealias Instant<Domain: ~Copyable & ~Escapable> = Tagged<Domain, Time.Instant>
}
