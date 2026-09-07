public import Tagged

extension Clock.Continuous.Deadline: Swift.Comparable {

    @inlinable
    public static func < (lhs: Clock.Continuous.Deadline, rhs: Clock.Continuous.Deadline) -> Bool {
        lhs.instant < rhs.instant
    }
}
