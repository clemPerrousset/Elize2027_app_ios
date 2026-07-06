import SwiftUI

struct ContentView: View {
    @State private var viewModel = VoteViewModel()

    var body: some View {
        Group {
            if viewModel.onboardingDone {
                VoteScreen(viewModel: viewModel)
            } else {
                OnboardingScreen { viewModel.markOnboardingDone() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.onboardingDone)
    }
}
