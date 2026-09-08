@_exported public import Tagged
@_exported public import Time

extension Clock {
    /// A temporal coordinate tagged with its clock domain.
    ///
    /// The provider defines the shared reference; it is not inherently the Unix
    /// epoch or boot time. A domain tag does not distinguish machines, boots, or
    /// independently chosen references. Only readings with a shared reference
    /// may be compared. All temporal arithmetic is supplied by Time and Tagged.
    public typealias Instant<Domain: ~Copyable & ~Escapable> = Tagged<Domain, Time.Coordinate>
}
