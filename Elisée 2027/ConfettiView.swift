import SwiftUI

private struct ConfettiParticle {
    let emoji: String
    let velX: Double
    let velY: Double
}

struct ConfettiView: View {
    let trigger: Int
    let origin: CGPoint

    @State private var startDate: Date? = nil
    @State private var particles: [ConfettiParticle] = []

    private let duration: Double = 0.85
    private let emojis = ["🇫🇷", "🇫🇷", "🇫🇷", "⭐", "🗼"]

    var body: some View {
        TimelineView(.animation(paused: isFinished)) { timeline in
            Canvas { ctx, _ in
                guard let start = startDate else { return }
                let t = min(timeline.date.timeIntervalSince(start) / duration, 1.0)
                for p in particles {
                    let x = origin.x + p.velX * t
                    let y = origin.y + p.velY * t + 480 * t * t
                    let alpha = max(0, 1 - t * 1.4)
                    var local = ctx
                    local.opacity = alpha
                    local.draw(
                        Text(p.emoji).font(.system(size: 18)),
                        at: CGPoint(x: x, y: y)
                    )
                }
            }
        }
        .onChange(of: trigger) {
            guard trigger > 0 else { return }
            particles = (0..<16).map { i in
                let angle = (Double(i) * (360.0 / 16.0) + Double.random(in: 0..<12)) * .pi / 180
                let speed = Double.random(in: 160...380)
                return ConfettiParticle(
                    emoji: emojis[i % emojis.count],
                    velX: cos(angle) * speed,
                    velY: sin(angle) * speed
                )
            }
            startDate = .now
        }
    }

    private var isFinished: Bool {
        guard let start = startDate else { return true }
        return Date.now.timeIntervalSince(start) >= duration
    }
}
