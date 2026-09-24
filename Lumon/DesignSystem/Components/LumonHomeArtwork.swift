import SwiftUI

/// A single motion field keeps the home shapes separated as they wander.
struct LumonHomeArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            HomeShapeField(size: proxy.size)
                .id("\(Int(proxy.size.width))-\(Int(proxy.size.height))")
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

private struct HomeShapeField: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var isVisible = false
    @State private var particles: [HomeParticle]

    let size: CGSize

    init(size: CGSize) {
        self.size = size
        _particles = State(initialValue: Self.makeParticles(in: size))
    }

    var body: some View {
        Canvas { context, _ in
            for particle in particles {
                context.drawLayer { layer in
                    layer.translateBy(x: particle.position.x, y: particle.position.y)
                    layer.rotate(by: .degrees(particle.angle))
                    layer.fill(
                        Self.path(for: particle.kind, size: particle.size),
                        with: .color(particle.color.opacity(0.72))
                    )
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .task(id: isVisible && scenePhase == .active && !reduceMotion) {
            guard isVisible && scenePhase == .active && !reduceMotion else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .milliseconds(33))
                } catch {
                    return
                }
                advanceParticles()
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }

    private func advanceParticles() {
        let delta: CGFloat = 1.0 / 30.0
        var next = particles

        for index in next.indices {
            var particle = next[index]
            particle.retargetAfter -= Double(delta)

            let toTarget = CGVector(
                dx: particle.target.x - particle.position.x,
                dy: particle.target.y - particle.position.y
            )
            let distance = hypot(toTarget.dx, toTarget.dy)
            if particle.retargetAfter <= 0 || distance < 12 {
                particle.target = Self.spreadTarget(for: index, among: next)
                particle.retargetAfter = Double.random(in: 2...5)
                particle.speed = CGFloat.random(in: 20...48)
                particle.spin = Double.random(in: -14...14)
            }

            let dx = particle.target.x - particle.position.x
            let dy = particle.target.y - particle.position.y
            let length = max(1, hypot(dx, dy))
            var desiredX = dx / length * particle.speed
            var desiredY = dy / length * particle.speed
            for otherIndex in next.indices where otherIndex != index {
                let other = next[otherIndex]
                let awayX = particle.position.x - other.position.x
                let awayY = particle.position.y - other.position.y
                let separation = max(1, hypot(awayX, awayY))
                if separation < 110 {
                    let push = (110 - separation) / 110 * particle.speed * 0.8
                    desiredX += awayX / separation * push
                    desiredY += awayY / separation * push
                }
            }
            particle.velocity.dx += (desiredX - particle.velocity.dx) * 0.06
            particle.velocity.dy += (desiredY - particle.velocity.dy) * 0.06
            let velocityLength = hypot(particle.velocity.dx, particle.velocity.dy)
            let speedLimit = particle.speed * 1.1
            if velocityLength > speedLimit {
                particle.velocity.dx *= speedLimit / velocityLength
                particle.velocity.dy *= speedLimit / velocityLength
            }

            let proposed = CGPoint(
                x: particle.position.x + particle.velocity.dx * delta,
                y: particle.position.y + particle.velocity.dy * delta
            )
            let margin = particle.radius + 3
            let insidePage = proposed.x >= margin && proposed.x <= size.width - margin
                && proposed.y >= margin && proposed.y <= size.height - margin
            let separated = next.indices.allSatisfy { otherIndex in
                guard otherIndex != index else { return true }
                let other = next[otherIndex]
                return hypot(proposed.x - other.position.x, proposed.y - other.position.y)
                    >= particle.radius + other.radius + 4
            }

            if insidePage && particle.roamingArea.contains(proposed) && separated {
                particle.position = proposed
            } else {
                particle.velocity.dx *= -0.35
                particle.velocity.dy *= -0.35
                particle.target = Self.spreadTarget(for: index, among: next)
                particle.retargetAfter = Double.random(in: 1.5...3.5)
                particle.speed = CGFloat.random(in: 20...48)
            }

            particle.angle = (particle.angle + particle.spin * Double(delta))
                .truncatingRemainder(dividingBy: 360)
            next[index] = particle
        }

        particles = next
    }

    private static func makeParticles(in size: CGSize) -> [HomeParticle] {
        guard size.width > 120, size.height > 120 else { return [] }
        let count = size.height < 500 ? 10 : (size.width >= 700 ? 24 : 14)
        let blueCount = max(4, count / 4)
        let yellowCount = (count - blueCount) / 2
        var colors = (
            Array(repeating: LumonPalette.red, count: count - blueCount - yellowCount)
                + Array(repeating: LumonPalette.yellow, count: yellowCount)
                + Array(repeating: LumonPalette.blue, count: blueCount)
        ).shuffled()
        let grid = gridDimensions(in: size)
        let cells = startingCells(count: count, grid: grid)
        var result: [HomeParticle] = []

        for (id, cell) in cells.enumerated() {
            let shapeSize = CGFloat.random(in: 18...min(62, min(size.width, size.height) * 0.15))
            let radius = shapeSize * 0.72
            var start: CGPoint?
            var startCell = cell

            for attempt in 0..<250 {
                let candidateCell = attempt < 80 ? cell : cells.randomElement() ?? cell
                let candidate = randomPoint(
                    in: candidateCell, grid: grid, size: size, margin: radius + 3
                )
                let separated = result.allSatisfy { other in
                    hypot(candidate.x - other.position.x, candidate.y - other.position.y)
                        >= radius + other.radius + 4
                }
                if separated {
                    start = candidate
                    startCell = candidateCell
                    break
                }
            }

            guard let start else { continue }
            let kind = HomeShapeKind.allCases.randomElement() ?? .circle
            let angle = Double.random(in: -30...30)
            result.append(HomeParticle(
                id: id,
                kind: kind,
                color: colors.removeLast(),
                size: shapeSize,
                position: start,
                roamingArea: roamingArea(
                    for: startCell, grid: grid, size: size, margin: radius + 3
                ),
                velocity: CGVector(dx: 0, dy: 0),
                target: start,
                speed: CGFloat.random(in: 20...48),
                retargetAfter: Double.random(in: 2...5),
                angle: angle,
                spin: Double.random(in: -14...14)
            ))
        }

        for index in result.indices {
            result[index].target = spreadTarget(for: index, among: result)
        }
        return result
    }

    private static func gridDimensions(in size: CGSize) -> (columns: Int, rows: Int) {
        let columns = size.width >= 700 ? max(7, Int(size.width / 120)) : 4
        let rows = size.height < 500 ? 5 : max(7, Int(size.height / 120))
        return (columns, rows)
    }

    private static func startingCells(
        count: Int, grid: (columns: Int, rows: Int)
    ) -> [Int] {
        var available = (0..<(grid.columns * grid.rows)).filter {
            isPerimeterCell($0, grid: grid)
        }
        var selected: [Int] = []

        while selected.count < count, !available.isEmpty {
            let ranked = available.map { cell -> (Int, CGFloat) in
                let center = cellCenter(cell, grid: grid)
                let clearance = selected.map {
                    let other = cellCenter($0, grid: grid)
                    return hypot(center.x - other.x, center.y - other.y)
                }.min() ?? 1
                return (cell, clearance + CGFloat.random(in: -0.08...0.08))
            }.sorted { $0.1 > $1.1 }
            let chosen = ranked.prefix(3).randomElement()?.0 ?? available[0]
            selected.append(chosen)
            available.removeAll { $0 == chosen }
        }

        return selected.shuffled()
    }

    private static func cellCenter(
        _ cell: Int, grid: (columns: Int, rows: Int)
    ) -> CGPoint {
        CGPoint(
            x: (CGFloat(cell % grid.columns) + 0.5) / CGFloat(grid.columns),
            y: (CGFloat(cell / grid.columns) + 0.5) / CGFloat(grid.rows)
        )
    }

    private static func isPerimeterCell(
        _ cell: Int, grid: (columns: Int, rows: Int)
    ) -> Bool {
        let column = cell % grid.columns
        let row = cell / grid.columns
        return column == 0 || column == grid.columns - 1
            || row == 0 || row == grid.rows - 1
    }

    private static func randomPoint(
        in cell: Int, grid: (columns: Int, rows: Int), size: CGSize, margin: CGFloat
    ) -> CGPoint {
        let cellWidth = size.width / CGFloat(grid.columns)
        let cellHeight = size.height / CGFloat(grid.rows)
        let column = cell % grid.columns
        let row = cell / grid.columns
        let x = (CGFloat(column) + 0.5) * cellWidth
            + CGFloat.random(in: -cellWidth * 0.22...cellWidth * 0.22)
        let y = (CGFloat(row) + 0.5) * cellHeight
            + CGFloat.random(in: -cellHeight * 0.22...cellHeight * 0.22)
        return CGPoint(
            x: min(max(x, margin), size.width - margin),
            y: min(max(y, margin), size.height - margin)
        )
    }

    private static func roamingArea(
        for cell: Int, grid: (columns: Int, rows: Int), size: CGSize, margin: CGFloat
    ) -> CGRect {
        // Each shape wanders along its own edge so paths cannot converge in the middle.
        let column = cell % grid.columns
        let row = cell / grid.columns
        let cellWidth = size.width / CGFloat(grid.columns)
        let cellHeight = size.height / CGFloat(grid.rows)
        let centerX = (CGFloat(column) + 0.5) * cellWidth
        let centerY = (CGFloat(row) + 0.5) * cellHeight

        if row == 0 || row == grid.rows - 1 {
            let minX = max(margin, centerX - cellWidth * 1.15)
            let maxX = min(size.width - margin, centerX + cellWidth * 1.15)
            let bandHeight = min(size.height * 0.28, cellHeight * 1.8)
            let minY = row == 0 ? margin : size.height - bandHeight
            let maxY = row == 0 ? bandHeight : size.height - margin
            return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }

        let bandWidth = min(size.width * 0.28, cellWidth * 1.8)
        let minX = column == 0 ? margin : size.width - bandWidth
        let maxX = column == 0 ? bandWidth : size.width - margin
        let minY = max(margin, centerY - cellHeight * 1.15)
        let maxY = min(size.height - margin, centerY + cellHeight * 1.15)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private static func spreadTarget(
        for index: Int, among particles: [HomeParticle]
    ) -> CGPoint {
        let current = particles[index]
        let area = current.roamingArea
        var best = current.position
        var bestScore = -Double.infinity

        for _ in 0..<24 {
            let candidate = CGPoint(
                x: CGFloat.random(in: area.minX...area.maxX),
                y: CGFloat.random(in: area.minY...area.maxY)
            )
            var nearestPosition = CGFloat.greatestFiniteMagnitude
            var nearestTarget = CGFloat.greatestFiniteMagnitude

            for otherIndex in particles.indices where otherIndex != index {
                let other = particles[otherIndex]
                nearestPosition = min(nearestPosition,
                    hypot(candidate.x - other.position.x, candidate.y - other.position.y)
                        - current.radius - other.radius)
                nearestTarget = min(nearestTarget,
                    hypot(candidate.x - other.target.x, candidate.y - other.target.y)
                        - current.radius - other.radius)
            }

            let travel = hypot(candidate.x - current.position.x, candidate.y - current.position.y)
            let score = Double(min(nearestPosition, 140)) * 0.5
                + Double(min(nearestTarget, 140)) * 0.7
                + Double(min(travel, 140)) * 0.15
                + Double.random(in: 0...20)
            if score > bestScore {
                best = candidate
                bestScore = score
            }
        }

        return best
    }

    private static func path(for kind: HomeShapeKind, size: CGFloat) -> Path {
        let half = size / 2
        switch kind {
        case .circle:
            return Path(ellipseIn: CGRect(x: -half, y: -half, width: size, height: size))
        case .square:
            return Path(CGRect(x: -half, y: -half, width: size, height: size))
        case .triangle:
            return Path { path in
                path.move(to: CGPoint(x: 0, y: -half))
                path.addLine(to: CGPoint(x: half, y: half))
                path.addLine(to: CGPoint(x: -half, y: half))
                path.closeSubpath()
            }
        }
    }
}

private enum HomeShapeKind: CaseIterable {
    case circle, square, triangle
}

private struct HomeParticle: Identifiable {
    let id: Int
    let kind: HomeShapeKind
    let color: Color
    let size: CGFloat
    var position: CGPoint
    let roamingArea: CGRect
    var velocity: CGVector
    var target: CGPoint
    var speed: CGFloat
    var retargetAfter: Double
    var angle: Double
    var spin: Double

    var radius: CGFloat { size * 0.72 }
}
