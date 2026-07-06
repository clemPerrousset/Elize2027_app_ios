import SwiftUI

struct CandidateCardView: View {
    let candidate: CandidateUiState
    let rank: Int
    var enabled: Bool = true

    private var info: CandidateInfo { candidate.info }
    private var partyColor: Color { info.color }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                rankBadge
                Spacer().frame(width: 8)
                avatar
                Spacer().frame(width: 12)
                namePartyColumn
                Spacer(minLength: 8)
                voteCountColumn
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, candidate.voteCount > 0 ? 10 : 14)

            if candidate.voteCount > 0 { progressBar }
            colorStripe
        }
        .background(candidate.isVotedFor ? partyColor.opacity(0.08) : Color(hex: "#1A1A2E"))
        .clipShape(RoundedCornerShape(radius: 16))
        .overlay(
            RoundedCornerShape(radius: 16)
                .stroke(borderBrush, lineWidth: candidate.isVotedFor ? 2 : 0)
        )
        .opacity(enabled ? 1 : 0.5)
    }

    // MARK: - Sub-views

    private var rankBadge: some View {
        let color: Color = switch rank {
            case 1: Color(hex: "#FFD700")
            case 2: Color(hex: "#B0BEC5")
            case 3: Color(hex: "#CD7F32")
            default: .secondary
        }
        return Text("\(rank)")
            .font(.system(size: 13, weight: rank <= 3 ? .black : .bold))
            .foregroundStyle(color)
            .frame(width: 22, alignment: .leading)
    }

    private var avatar: some View {
        Group {
            if let url = info.photoURL {
                RemoteImage(url: url, initials: info.initials, color: partyColor)
            } else {
                Text(info.initials)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(partyColor)
            }
        }
        .frame(width: 68, height: 68)
        .clipShape(Circle())
        .background(partyColor.opacity(0.2), in: Circle())
    }

    private var namePartyColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(info.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            partyChip
        }
    }

    private var partyChip: some View {
        Text(info.party)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(partyColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(partyColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 6))
            .lineLimit(1)
    }

    private var voteCountColumn: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if candidate.isVotedFor {
                Text("✓")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(partyColor)
                    .transition(.opacity.combined(with: .scale))
            }
            if candidate.voteCount > 0 {
                Text(formatCount(candidate.voteCount))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(candidate.voteCount == 1 ? "vote" : "votes")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Color(hex: "#2A2A45")
                if let grad = info.gradient {
                    grad.frame(width: geo.size.width * candidate.progressFraction)
                } else {
                    partyColor.frame(width: geo.size.width * candidate.progressFraction)
                }
            }
        }
        .frame(height: 4)
        .animation(.easeOut(duration: 0.6), value: candidate.progressFraction)
    }

    private var colorStripe: some View {
        Rectangle()
            .fill(borderBrush)
            .frame(height: 3)
    }

    private var borderBrush: AnyShapeStyle {
        if let grad = info.gradient {
            AnyShapeStyle(grad)
        } else {
            AnyShapeStyle(partyColor.opacity(0.5))
        }
    }
}

// MARK: - Helpers

private struct RoundedCornerShape: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: radius)
    }
}

private func formatCount(_ count: Int) -> String {
    guard count >= 1000 else { return "\(count)" }
    let k = count / 1000
    let r = (count % 1000) / 100
    return r == 0 ? "\(k)k" : "\(k),\(r)k"
}
