import Foundation

struct VoteAPI {
    private let serverURL: String

    init(serverURL: String = Config.serverURL) {
        self.serverURL = serverURL
    }

    func getVotes() async throws -> [CandidateCount] {
        let url = URL(string: "\(serverURL)/votes")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(VoteCountResponse.self, from: data).candidates
    }

    func getDeviceVote(phoneId: String) async throws -> String? {
        let url = URL(string: "\(serverURL)/votes/\(phoneId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(DeviceVoteResponse.self, from: data).candidate_id
    }

    func castVote(phoneId: String, candidateId: String, token: String) async throws {
        var request = URLRequest(url: URL(string: "\(serverURL)/vote")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            VoteRequest(phone_id: phoneId, candidate_id: candidateId, token: token)
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VoteApiResponse.self, from: data)
        if let err = response.error { throw VoteError.server(err) }
    }
}

enum VoteError: LocalizedError {
    case server(String)
    var errorDescription: String? {
        if case .server(let msg) = self { return msg }
        return nil
    }
}
