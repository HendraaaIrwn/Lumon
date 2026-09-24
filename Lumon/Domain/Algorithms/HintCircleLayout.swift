import Foundation

/// A deterministic, fully-contained arrangement for the hint circles drawn in
/// one puzzle shape. Centers are normalized to the shape's local bounds while
/// the diameter is expressed in rendered points.
nonisolated struct HintCircleLayout: Equatable, Sendable {
    let diameter: Double
    let centers: [NormalizedPoint]
}

/// Produces hint-circle placements which stay inside the unrotated shape.
/// `ClueDotsView` rotates the completed cluster with its parent shape, so that
/// rigid transform preserves both containment and spacing.
nonisolated struct HintCircleLayoutEngine: Sendable {
    /// Narrow authored polygons in the 240-point catalog need this floor to
    /// keep their existing clues visible without changing their geometry.
    static let minimumDiameter = 6.0
    static let maximumDiameter = 14.0
    static let edgeClearance = 1.0
    static let circleSpacing = 1.0
    /// Compact shapes may need a larger relative mark, but circles still need
    /// enough room for the requested count and boundary clearance.
    static let maximumRelativeDiameter = 0.45
    private static let maximumBeamWidth = 96
    private static let maximumOptimizedCandidateCount = 64
    private static let maximumDenseGridCandidateCount = 1_024

    func layout(
        type: ShapeType,
        points: [NormalizedPoint],
        clueCount: Int,
        renderedWidth: Double,
        renderedHeight: Double
    ) -> HintCircleLayout? {
        guard clueCount > 0,
              renderedWidth.isFinite,
              renderedHeight.isFinite,
              renderedWidth > 0,
              renderedHeight > 0 else {
            return clueCount == 0 ? HintCircleLayout(diameter: 0, centers: []) : nil
        }

        let width: Double
        let height: Double
        if type == .square || type == .circle {
            let side = min(renderedWidth, renderedHeight)
            width = side
            height = side
        } else {
            width = renderedWidth
            height = renderedHeight
        }

        let shortestSide = min(width, height)
        let targetFraction: Double = switch clueCount {
        case 1: 0.20
        case 2...3: 0.17
        default: 0.14
        }
        let maximumRelativeDiameter = shortestSide * Self.maximumRelativeDiameter
        guard maximumRelativeDiameter + 0.000_1 >= Self.minimumDiameter else { return nil }

        var diameter = min(
            Self.maximumDiameter,
            min(
                maximumRelativeDiameter,
                max(Self.minimumDiameter, shortestSide * targetFraction)
            )
        )
        while diameter + 0.000_1 >= Self.minimumDiameter {
            if let centers = placements(
                type: type,
                points: points,
                count: clueCount,
                width: width,
                height: height,
                diameter: diameter
            ) {
                return HintCircleLayout(
                    diameter: diameter,
                    centers: centers.map {
                        NormalizedPoint(x: $0.x / width, y: $0.y / height)
                    }
                )
            }
            diameter -= 0.5
        }

        return nil
    }

    /// Returns the visual center that a hint-circle group should target before
    /// its parent shape is rotated. Polygon centroids use the signed area so
    /// asymmetric authored geometry does not fall back to its bounding box.
    func targetCenter(type: ShapeType, points: [NormalizedPoint]) -> NormalizedPoint {
        if type == .circle {
            return NormalizedPoint(x: 0.5, y: 0.5)
        }

        let boundary = boundaryPoints(type: type, points: points, width: 1, height: 1)
        guard boundary.count >= 3 else {
            return NormalizedPoint(x: 0.5, y: 0.5)
        }

        var twiceArea = 0.0
        var centroidX = 0.0
        var centroidY = 0.0
        for index in boundary.indices {
            let current = boundary[index]
            let next = boundary[(index + 1) % boundary.count]
            let cross = current.x * next.y - next.x * current.y
            twiceArea += cross
            centroidX += (current.x + next.x) * cross
            centroidY += (current.y + next.y) * cross
        }

        guard abs(twiceArea) > 0.000_1 else {
            return NormalizedPoint(x: 0.5, y: 0.5)
        }
        return NormalizedPoint(
            x: centroidX / (3 * twiceArea),
            y: centroidY / (3 * twiceArea)
        )
    }

    private func placements(
        type: ShapeType,
        points: [NormalizedPoint],
        count: Int,
        width: Double,
        height: Double,
        diameter: Double
    ) -> [Point]? {
        let requiredClearance = diameter / 2 + Self.edgeClearance
        let minimumDistance = diameter + Self.circleSpacing
        let candidateStep = min(width, height) < 48 ? 0.25 : max(1, diameter / 2)
        let normalizedTarget = targetCenter(type: type, points: points)
        let target = Point(
            x: normalizedTarget.x * width,
            y: normalizedTarget.y * height
        )
        let candidates = candidates(
            type: type,
            points: points,
            width: width,
            height: height,
            requiredClearance: requiredClearance,
            step: candidateStep,
            target: target
        )
        guard candidates.count >= count else { return nil }

        let ordered = candidates.sorted {
            let leftDistance = squaredDistance($0.point, target)
            let rightDistance = squaredDistance($1.point, target)
            if leftDistance != rightDistance { return leftDistance < rightDistance }
            if $0.point.y != $1.point.y { return $0.point.y < $1.point.y }
            return $0.point.x < $1.point.x
        }

        return bestCenteredArrangement(
            from: ordered,
            count: count,
            minimumDistance: minimumDistance,
            target: target,
            maximumCandidateCount: candidateStep < 1
                ? Self.maximumDenseGridCandidateCount
                : Self.maximumOptimizedCandidateCount
        )?.map(\.point)
    }

    private func candidates(
        type: ShapeType,
        points: [NormalizedPoint],
        width: Double,
        height: Double,
        requiredClearance: Double,
        step: Double,
        target: Point
    ) -> [Candidate] {
        if type == .circle {
            let radius = min(width, height) / 2
            let center = Point(x: width / 2, y: height / 2)
            return grid(width: width, height: height, step: step, target: target).compactMap { point in
                let clearance = radius - distance(point, center)
                guard clearance + 0.000_1 >= requiredClearance else { return nil }
                return Candidate(point: point, clearance: clearance - requiredClearance)
            }
        }

        let boundary = boundaryPoints(type: type, points: points, width: width, height: height)
        guard boundary.count >= 3 else { return [] }
        return grid(width: width, height: height, step: step, target: target).compactMap { point in
            guard isInside(point, boundary: boundary) else { return nil }
            let clearance = boundary.indices
                .map { distance(point, toSegmentFrom: boundary[$0], to: boundary[($0 + 1) % boundary.count]) }
                .min() ?? 0
            guard clearance + 0.000_1 >= requiredClearance else { return nil }
            return Candidate(point: point, clearance: clearance - requiredClearance)
        }
    }

    private func boundaryPoints(
        type: ShapeType,
        points: [NormalizedPoint],
        width: Double,
        height: Double
    ) -> [Point] {
        let normalized: [NormalizedPoint] = switch type {
        case .triangle:
            [NormalizedPoint(x: 0.5, y: 0), NormalizedPoint(x: 1, y: 1), NormalizedPoint(x: 0, y: 1)]
        case .square:
            [NormalizedPoint(x: 0, y: 0), NormalizedPoint(x: 1, y: 0), NormalizedPoint(x: 1, y: 1), NormalizedPoint(x: 0, y: 1)]
        case .diamond:
            [NormalizedPoint(x: 0.5, y: 0), NormalizedPoint(x: 1, y: 0.5), NormalizedPoint(x: 0.5, y: 1), NormalizedPoint(x: 0, y: 0.5)]
        case .polygon:
            points
        case .circle:
            []
        }
        return normalized.map { Point(x: $0.x * width, y: $0.y * height) }
    }

    private func grid(width: Double, height: Double, step: Double, target: Point) -> [Point] {
        var result: [Point] = []
        var seen: Set<Point> = []
        let boundedTarget = Point(
            x: min(width, max(0, target.x)),
            y: min(height, max(0, target.y))
        )

        func appendLattice(centeredOn origin: Point) {
            var startY = origin.y
            while startY - step >= 0 { startY -= step }
            while startY < 0 { startY += step }

            var y = startY
            while y <= height + 0.000_1 {
                var startX = origin.x
                while startX - step >= 0 { startX -= step }
                while startX < 0 { startX += step }

                var x = startX
                while x <= width + 0.000_1 {
                    let point = Point(x: x, y: y)
                    if seen.insert(point).inserted {
                        result.append(point)
                    }
                    x += step
                }
                y += step
            }
        }

        appendLattice(centeredOn: Point(x: 0, y: 0))
        appendLattice(centeredOn: boundedTarget)
        return result
    }

    private func isInside(_ point: Point, boundary: [Point]) -> Bool {
        var isInside = false
        for index in boundary.indices {
            let current = boundary[index]
            let next = boundary[(index + 1) % boundary.count]
            guard (current.y > point.y) != (next.y > point.y) else { continue }
            let crossingX = (next.x - current.x) * (point.y - current.y)
                / (next.y - current.y) + current.x
            if point.x < crossingX { isInside.toggle() }
        }
        return isInside
    }

    private func distance(_ point: Point, toSegmentFrom start: Point, to end: Point) -> Double {
        let segmentX = end.x - start.x
        let segmentY = end.y - start.y
        let lengthSquared = segmentX * segmentX + segmentY * segmentY
        guard lengthSquared > 0 else { return distance(point, start) }
        let projection = ((point.x - start.x) * segmentX + (point.y - start.y) * segmentY) / lengthSquared
        let clamped = min(1, max(0, projection))
        return distance(point, Point(x: start.x + segmentX * clamped, y: start.y + segmentY * clamped))
    }

    private func distance(_ lhs: Point, _ rhs: Point) -> Double {
        hypot(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    private func squaredDistance(_ lhs: Point, _ rhs: Point) -> Double {
        let x = lhs.x - rhs.x
        let y = lhs.y - rhs.y
        return x * x + y * y
    }

    private func bestCenteredArrangement(
        from candidates: [Candidate],
        count: Int,
        minimumDistance: Double,
        target: Point,
        maximumCandidateCount: Int
    ) -> [Candidate]? {
        let optimizedCandidates = Array(candidates.prefix(maximumCandidateCount))
        var states = [ArrangementState(selected: [], nextIndex: 0)]
        for _ in 0..<count {
            var nextStates: [ArrangementState] = []
            for state in states {
                let remainingAfterSelection = count - state.selected.count - 1
                let maximumIndex = optimizedCandidates.count - remainingAfterSelection - 1
                guard state.nextIndex <= maximumIndex else { continue }
                for index in state.nextIndex...maximumIndex {
                    let candidate = optimizedCandidates[index]
                    guard state.selected.allSatisfy({
                        distance(candidate.point, $0.point) + 0.000_1 >= minimumDistance
                    }) else { continue }
                    nextStates.append(
                        ArrangementState(
                            selected: state.selected + [candidate],
                            nextIndex: index + 1
                        )
                    )
                }
            }
            guard !nextStates.isEmpty else {
                return firstValidArrangement(
                    from: candidates,
                    count: count,
                    minimumDistance: minimumDistance
                )
            }
            states = nextStates.sorted {
                arrangementScore(for: $0.selected, target: target)
                    < arrangementScore(for: $1.selected, target: target)
            }
            if states.count > Self.maximumBeamWidth {
                states.removeLast(states.count - Self.maximumBeamWidth)
            }
        }

        return states.min {
            arrangementScore(for: $0.selected, target: target)
                < arrangementScore(for: $1.selected, target: target)
        }?.selected ?? firstValidArrangement(
            from: candidates,
            count: count,
            minimumDistance: minimumDistance
        )
    }

    private func firstValidArrangement(
        from candidates: [Candidate],
        count: Int,
        minimumDistance: Double
    ) -> [Candidate]? {
        func search(start: Int, selected: [Candidate]) -> [Candidate]? {
            if selected.count == count { return selected }
            let remaining = count - selected.count
            let maximumIndex = candidates.count - remaining
            guard start <= maximumIndex else { return nil }
            for index in start...maximumIndex {
                let candidate = candidates[index]
                guard selected.allSatisfy({
                    distance(candidate.point, $0.point) + 0.000_1 >= minimumDistance
                }) else { continue }
                if let result = search(start: index + 1, selected: selected + [candidate]) {
                    return result
                }
            }
            return nil
        }
        return search(start: 0, selected: [])
    }

    private func arrangementScore(for selected: [Candidate], target: Point) -> ArrangementScore {
        let count = Double(selected.count)
        let center = Point(
            x: selected.map(\.point.x).reduce(0, +) / count,
            y: selected.map(\.point.y).reduce(0, +) / count
        )
        let radii = selected.map { distance($0.point, center) }
        let meanRadius = radii.reduce(0, +) / count
        let radialVariance = radii
            .map { radius in
                let difference = radius - meanRadius
                return difference * difference
            }
            .reduce(0, +) / count
        let spread = radii.map { $0 * $0 }.reduce(0, +) / count
        let angularVariance: Double
        if selected.count < 2 {
            angularVariance = 0
        } else {
            let angles = selected
                .map { atan2($0.point.y - center.y, $0.point.x - center.x) }
                .sorted()
            let expectedGap = 2 * Double.pi / count
            let gaps = angles.indices.map { index in
                let next = angles[(index + 1) % angles.count]
                let adjustedNext = index == angles.count - 1 ? next + 2 * Double.pi : next
                return adjustedNext - angles[index]
            }
            angularVariance = gaps
                .map { gap in
                    let difference = gap - expectedGap
                    return difference * difference
                }
                .reduce(0, +) / count
        }
        let minimumClearance = selected.map(\.clearance).min() ?? 0
        return ArrangementScore(
            centroidDistance: squaredDistance(center, target),
            radialVariance: radialVariance,
            angularVariance: angularVariance,
            spread: spread,
            negativeClearance: -minimumClearance,
            coordinates: selected.flatMap { [$0.point.y, $0.point.x] }
        )
    }

    private struct Point: Hashable, Sendable {
        let x: Double
        let y: Double
    }

    private struct Candidate: Sendable {
        let point: Point
        let clearance: Double
    }

    private struct ArrangementState: Sendable {
        let selected: [Candidate]
        let nextIndex: Int
    }

    private struct ArrangementScore: Comparable, Sendable {
        let centroidDistance: Double
        let radialVariance: Double
        let angularVariance: Double
        let spread: Double
        let negativeClearance: Double
        let coordinates: [Double]

        static func < (lhs: ArrangementScore, rhs: ArrangementScore) -> Bool {
            if lhs.centroidDistance != rhs.centroidDistance {
                return lhs.centroidDistance < rhs.centroidDistance
            }
            if lhs.radialVariance != rhs.radialVariance {
                return lhs.radialVariance < rhs.radialVariance
            }
            if lhs.angularVariance != rhs.angularVariance {
                return lhs.angularVariance < rhs.angularVariance
            }
            if lhs.spread != rhs.spread {
                return lhs.spread < rhs.spread
            }
            if lhs.negativeClearance != rhs.negativeClearance {
                return lhs.negativeClearance < rhs.negativeClearance
            }
            return lhs.coordinates.lexicographicallyPrecedes(rhs.coordinates)
        }
    }
}
