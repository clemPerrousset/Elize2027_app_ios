import SwiftUI
import Charts

private struct CandidateSeries: Identifiable {
    let id: String
    let name: String
    let color: Color
    let photoURL: URL?
    let initials: String
    /// One point per calendar day, ascending by date (last snapshot of each day).
    let points: [VoteHistoryPoint]
    var finalVotes: Int { points.last?.votes ?? 0 }
    var lastPoint: VoteHistoryPoint? { points.last }
}

/// Groups points by calendar day (device local time zone) and keeps only the
/// last snapshot (max date) recorded for each day, sorted ascending by day.
private func bucketedByDay(_ points: [VoteHistoryPoint]) -> [VoteHistoryPoint] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: points) { point in
        calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(point.date)))
    }
    return grouped.values
        .compactMap { dayPoints in dayPoints.max { $0.date < $1.date } }
        .sorted { $0.date < $1.date }
}

struct ProgressionScreen: View {
    var viewModel: VoteViewModel

    @State private var showAllCandidates = false

    private let topN = 8

    private var series: [CandidateSeries] {
        let byCandidate = Dictionary(grouping: viewModel.history, by: { $0.candidate_id })
        let infoById = Dictionary(uniqueKeysWithValues: allCandidates.map { ($0.id, $0) })

        return byCandidate.compactMap { (candidateId, points) -> CandidateSeries? in
            guard let info = infoById[candidateId] else { return nil }
            let sortedPoints = points.sorted { $0.date < $1.date }
            let dayPoints = bucketedByDay(sortedPoints)
            guard !dayPoints.isEmpty else { return nil }
            return CandidateSeries(
                id: candidateId,
                name: info.name,
                color: info.color,
                photoURL: info.photoURL,
                initials: info.initials,
                points: dayPoints
            )
        }.sorted { $0.finalVotes > $1.finalVotes }
    }

    private var visibleSeries: [CandidateSeries] {
        showAllCandidates ? series : Array(series.prefix(topN))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D0D1A").ignoresSafeArea()

                if viewModel.isLoadingHistory && viewModel.history.isEmpty {
                    ProgressView()
                        .tint(.white)
                } else if series.isEmpty {
                    ContentUnavailableFallback()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            chart
                                .frame(height: 280)
                                .padding(.leading)
                                .padding(.trailing, 32)
                                .padding(.top, 12)

                            if series.count > topN {
                                toggleButton
                                    .padding(.horizontal)
                            }

                            legend
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Progression")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .refreshable { await viewModel.loadHistory() }
            .task { await viewModel.loadHistoryIfNeeded() }
        }
    }

    private var chart: some View {
        Chart {
            ForEach(visibleSeries) { s in
                ForEach(s.points, id: \.date) { point in
                    LineMark(
                        x: .value("Date", Date(timeIntervalSince1970: TimeInterval(point.date))),
                        y: .value("Votes", point.votes)
                    )
                    .interpolationMethod(.monotone)
                }
                .foregroundStyle(s.color)

                // A lone LineMark segment can't be drawn for a series with a single
                // data point, so make sure it still shows up as a dot.
                if s.points.count == 1, let point = s.points.first {
                    PointMark(
                        x: .value("Date", Date(timeIntervalSince1970: TimeInterval(point.date))),
                        y: .value("Votes", point.votes)
                    )
                    .foregroundStyle(s.color)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine().foregroundStyle(.white.opacity(0.15))
                AxisValueLabel(format: .dateTime.day().month())
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(.white.opacity(0.15))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                let plotFrame = geo[proxy.plotAreaFrame]
                ZStack {
                    ForEach(visibleSeries) { s in
                        if let last = s.lastPoint,
                           let xPos = proxy.position(forX: Date(timeIntervalSince1970: TimeInterval(last.date))),
                           let yPos = proxy.position(forY: last.votes) {
                            EndOfLineAvatar(photoURL: s.photoURL, initials: s.initials, color: s.color)
                                .position(x: plotFrame.origin.x + xPos, y: plotFrame.origin.y + yPos)
                        }
                    }
                }
            }
        }
    }

    private var toggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { showAllCandidates.toggle() }
        } label: {
            Text(showAllCandidates ? "Afficher top \(topN)" : "Afficher tout (\(series.count))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Candidats")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                ForEach(visibleSeries) { s in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(s.color)
                            .frame(width: 10, height: 10)
                        Text(s.name)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Text("\(s.finalVotes)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

/// Small circular end-of-line marker reusing the same avatar treatment as
/// the Votes tab (RemoteImage with an initials/color fallback), just smaller.
private struct EndOfLineAvatar: View {
    let photoURL: URL?
    let initials: String
    let color: Color
    var size: CGFloat = 26

    var body: some View {
        Group {
            if let url = photoURL {
                RemoteImage(url: url, initials: initials, color: color)
            } else {
                Text(initials)
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size, height: size)
        .background(color.opacity(0.2), in: Circle())
        .clipShape(Circle())
        .overlay(Circle().stroke(color, lineWidth: 1.5))
    }
}

private struct ContentUnavailableFallback: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.4))
            Text("Pas encore de données")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}
