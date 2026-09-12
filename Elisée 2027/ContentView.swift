import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = VoteViewModel()
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        Group {
            if viewModel.onboardingDone {
                TabView {
                    VoteScreen(viewModel: viewModel)
                        .tabItem {
                            Label("Votes", systemImage: "checkmark.circle")
                        }
                    ProgressionScreen(viewModel: viewModel)
                        .tabItem {
                            Label("Progression", systemImage: "chart.line.uptrend.xyaxis")
                        }
                }
            } else {
                OnboardingScreen { viewModel.markOnboardingDone() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.onboardingDone)
        // Propose la notation native (fenêtre système App Store), juste après le premier vote.
        .onChange(of: viewModel.shouldRequestReview) { _, shouldRequest in
            guard shouldRequest else { return }
            requestReview()
            viewModel.shouldRequestReview = false
        }
    }
}
