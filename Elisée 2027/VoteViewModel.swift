import SwiftUI

@Observable
class VoteViewModel {
    var candidates: [CandidateUiState] = []
    var isLoading = false
    var error: String? = nil
    var cooldownSeconds = 0
    var onboardingDone: Bool
    var history: [VoteHistoryPoint] = []
    var isLoadingHistory = false
    // Bascule à `true` juste après le tout premier vote — observé par la vue pour
    // proposer la notation native (StoreKit), puis remis à `false`.
    var shouldRequestReview = false

    private let repo = VoteRepository()
    private let phoneId = getPhoneId()
    private var cooldownTask: Task<Void, Never>?
    private var hasLoadedHistory = false

    init() {
        onboardingDone = UserDefaults.standard.bool(forKey: "onboardingDone")
        candidates = allCandidates.map { CandidateUiState(info: $0) }
        Task { await fetchData() }
    }

    // MARK: - Public

    func fetchData() async {
        isLoading = true
        error = nil
        let token = generateHmacToken(phoneId: phoneId, secret: Config.hmacSecret)
        async let counts = repo.fetchVotes()
        async let votedId = repo.fetchDeviceVote(phoneId: phoneId, token: token)
        let (c, v) = await (counts, votedId)
        isLoading = false
        applyServerData(counts: c, votedId: v)
    }

    func refresh() async {
        await fetchData()
    }

    func loadHistoryIfNeeded() async {
        guard !hasLoadedHistory else { return }
        hasLoadedHistory = true
        await loadHistory()
    }

    func loadHistory() async {
        isLoadingHistory = true
        let ids = allCandidates.map(\.id)
        history = await repo.fetchHistory(candidateIds: ids)
        isLoadingHistory = false
    }

    func vote(candidateId: String) async {
        guard cooldownSeconds == 0 else { return }
        let previousVotedId = candidates.first(where: { $0.isVotedFor })?.id
        let newVotedId = candidateId == previousVotedId ? nil : candidateId

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            updateVoteLocally(newVoteId: newVotedId)
        }
        startCooldown()

        let token = generateHmacToken(phoneId: phoneId, secret: Config.hmacSecret)
        do {
            let isFirstEverVote = try await repo.castVote(phoneId: phoneId, candidateId: candidateId, token: token)
            if isFirstEverVote { shouldRequestReview = true }
        } catch {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                updateVoteLocally(newVoteId: previousVotedId)
            }
            self.error = error.localizedDescription
        }
    }

    func markOnboardingDone() {
        UserDefaults.standard.set(true, forKey: "onboardingDone")
        withAnimation { onboardingDone = true }
    }

    func clearError() { error = nil }

    // MARK: - Private

    private func startCooldown() {
        cooldownTask?.cancel()
        cooldownSeconds = 2
        cooldownTask = Task {
            for remaining in stride(from: 1, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                cooldownSeconds = remaining
            }
        }
    }

    private func applyServerData(counts: [CandidateCount], votedId: String?) {
        let countMap = Dictionary(uniqueKeysWithValues: counts.map { ($0.id, $0.count) })
        let maxCount = max(countMap.values.max() ?? 1, 1)

        candidates = allCandidates.map { info in
            CandidateUiState(
                info: info,
                voteCount: countMap[info.id] ?? 0,
                progressFraction: Double(countMap[info.id] ?? 0) / Double(maxCount),
                isVotedFor: info.id == votedId
            )
        }.sorted {
            $0.voteCount != $1.voteCount ? $0.voteCount > $1.voteCount : $0.info.name < $1.info.name
        }
    }

    private func updateVoteLocally(newVoteId: String?) {
        let oldVotedId = candidates.first(where: { $0.isVotedFor })?.id

        candidates = candidates.map { c in
            var copy = c
            if c.id == oldVotedId  { copy.voteCount = max(0, c.voteCount - 1); copy.isVotedFor = false }
            if c.id == newVoteId   { copy.voteCount = c.voteCount + 1;          copy.isVotedFor = true  }
            return copy
        }

        let maxCount = max(candidates.map(\.voteCount).max() ?? 1, 1)
        candidates = candidates.map { c in
            var copy = c
            copy.progressFraction = Double(c.voteCount) / Double(maxCount)
            return copy
        }.sorted {
            $0.voteCount != $1.voteCount ? $0.voteCount > $1.voteCount : $0.info.name < $1.info.name
        }
    }
}
