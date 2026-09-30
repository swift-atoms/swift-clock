extension Clock.Deadline {

    @inlinable public static func after<Domain: ~Copyable & ~Escapable>(
        _ duration: Swift.Duration,
        from instant: Instant
    ) -> Self where Instant == Clock.Instant<Domain> {
        .at(Instant(offset: instant.offset + duration))
    }

    @inlinable public func remaining<Domain: ~Copyable & ~Escapable>(
        at instant: Instant
    ) -> Swift.Duration? where Instant == Clock.Instant<Domain> {
        switch self {
        case .at(let deadline): instant.offset < deadline.offset ? deadline.offset - instant.offset : .zero
        case .never: nil
        }
    }
}
