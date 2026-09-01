import SwiftUI

struct VoteScreen: View {
    var viewModel: VoteViewModel

    @State private var explosionTrigger = 0
    @State private var explosionOrigin = CGPoint.zero
    @State private var cardCenters: [String: CGPoint] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D0D1A").ignoresSafeArea()

                List {
                    ForEach(Array(viewModel.candidates.enumerated()), id: \.element.id) { index, candidate in
                        CandidateCardView(
                            candidate: candidate,
                            rank: index + 1,
                            enabled: viewModel.cooldownSeconds == 0
                        )
                        .onGeometryChange(for: CGPoint.self) { geo in
                            let frame = geo.frame(in: .global)
                            return CGPoint(x: frame.midX, y: frame.midY)
                        } action: { center in
                            cardCenters[candidate.id] = center
                        }
                        .onTapGesture {
                            guard viewModel.cooldownSeconds == 0 else { return }
                            explosionOrigin = cardCenters[candidate.id] ?? CGPoint(x: 200, y: 400)
                            explosionTrigger += 1
                            Task { await viewModel.vote(candidateId: candidate.info.id) }
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, 4)
                .padding(.bottom, 80)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.candidates.map(\.id))
                .refreshable { await viewModel.refresh() }

                // Cooldown pill
                if viewModel.cooldownSeconds > 0 {
                    VStack {
                        Spacer()
                        Text("Attendez \(viewModel.cooldownSeconds)…")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 24)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Confetti overlay
                ConfettiView(trigger: explosionTrigger, origin: explosionOrigin)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
            .navigationTitle("Elisée 2027")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack(spacing: 4) {
                        Button {
                            Task { await viewModel.refresh() }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView().scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.error ?? "")
        }
    }
}
