public import Tagged
public import Time

public enum Clock {}

extension Clock {

    public typealias Instant<Domain: ~Copyable & ~Escapable> = Tagged<Domain, Time.Coordinate>
}
