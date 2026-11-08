public import Tagged
public import Time

extension Clock {

    public typealias Instant<Domain: ~Copyable & ~Escapable> = Tagged<Domain, Time.Coordinate>
}
