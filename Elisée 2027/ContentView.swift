import SwiftUI

struct ContentView: View {
    @State private var viewModel = VoteViewModel()

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
    }
}
