import Foundation

private let kVotedCandidateKey = "votedCandidate"
private let kHasVotedBeforeKey = "hasVotedBefore"

struct VoteRepository {
    private let api = VoteAPI()

    func fetchVotes() async -> [CandidateCount] {
        (try? await api.getVotes()) ?? []
    }

    func fetchHistory(candidateIds: [String]) async -> [VoteHistoryPoint] {
        (try? await api.getVotesHistory(candidateIds: candidateIds)) ?? []
    }

    func fetchDeviceVote(phoneId: String, token: String) async -> String? {
        if let serverVote = try? await api.getDeviceVote(phoneId: phoneId, token: token) {
            UserDefaults.standard.set(serverVote, forKey: kVotedCandidateKey)
            return serverVote
        }
        return UserDefaults.standard.string(forKey: kVotedCandidateKey)
    }

    /// Vote, puis renvoie `true` si c'était le tout premier vote jamais effectué sur cet appareil
    /// (utilisé pour proposer la notation native une seule fois, juste après ce premier vote).
    @discardableResult
    func castVote(phoneId: String, candidateId: String, token: String) async throws -> Bool {
        try await api.castVote(phoneId: phoneId, candidateId: candidateId, token: token)
        UserDefaults.standard.set(candidateId, forKey: kVotedCandidateKey)

        let isFirstEverVote = !UserDefaults.standard.bool(forKey: kHasVotedBeforeKey)
        if isFirstEverVote {
            UserDefaults.standard.set(true, forKey: kHasVotedBeforeKey)
        }
        return isFirstEverVote
    }
}
