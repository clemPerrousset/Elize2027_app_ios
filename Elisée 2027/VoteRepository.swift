import Foundation

private let kVotedCandidateKey = "votedCandidate"

struct VoteRepository {
    private let api = VoteAPI()

    func fetchVotes() async -> [CandidateCount] {
        (try? await api.getVotes()) ?? []
    }

    func fetchHistory(candidateIds: [String]) async -> [VoteHistoryPoint] {
        (try? await api.getVotesHistory(candidateIds: candidateIds)) ?? []
    }

    func fetchDeviceVote(phoneId: String) async -> String? {
        if let serverVote = try? await api.getDeviceVote(phoneId: phoneId) {
            UserDefaults.standard.set(serverVote, forKey: kVotedCandidateKey)
            return serverVote
        }
        return UserDefaults.standard.string(forKey: kVotedCandidateKey)
    }

    func castVote(phoneId: String, candidateId: String, token: String) async throws {
        try await api.castVote(phoneId: phoneId, candidateId: candidateId, token: token)
        UserDefaults.standard.set(candidateId, forKey: kVotedCandidateKey)
    }
}
