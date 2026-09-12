import SwiftUI
import Charts

private struct CandidateSeries: Identifiable {
    let id: String
    let name: String
    let color: Color
    let points: [VoteHistoryPoint]
    var finalVotes: Int { points.last?.votes ?? 0 }
}

struct ProgressionScreen: View {
    var viewModel: VoteViewModel

    private var series: [CandidateSeries] {
        let byCandidate = Dictionary(grouping: viewModel.history, by: { $0.candidate_id })
        let infoById = Dictionary(uniqueKeysWithValues: allCandidates.map { ($0.id, $0) })

        return byCandidate.compactMap { (candidateId, points) -> CandidateSeries? in
            guard let info = infoById[candidateId] else { return nil }
            let sortedPoints = points.sorted { $0.date < $1.date }
            guard !sortedPoints.isEmpty else { return nil }
            return CandidateSeries(id: candidateId, name: info.name, color: info.color, points: sortedPoints)
        }.sorted { $0.finalVotes > $1.finalVotes }
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
                                .padding(.horizontal)
                                .padding(.top, 12)

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
            ForEach(series) { s in
                ForEach(s.points, id: \.date) { point in
                    LineMark(
                        x: .value("Date", Date(timeIntervalSince1970: TimeInterval(point.date))),
                        y: .value("Votes", point.votes)
                    )
                    .interpolationMethod(.monotone)
                }
                .foregroundStyle(s.color)
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
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Candidats")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                ForEach(series) { s in
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
