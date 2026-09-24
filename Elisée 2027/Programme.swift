import Foundation

// MARK: - Programmes des candidats
// Données embarquées dans programmes.json (bundle), générées par programmes_data/merge.py
// (ne pas éditer à la main : modifier programmes_data/candidates/<id>.json puis relancer le script).

struct ProgrammesFile: Decodable {
    let updatedAt: String
    let programmes: [Programme]
}

struct Programme: Decodable {
    let candidateId: String
    let status: String
    let statusNote: String?
    let officialUrl: String?
    let officialUrlLabel: String?
    let officialUrlIsProgramme: Bool?
    let programmeNote: String?
    let highlights: [String]?
    let themes: [ProgrammeTheme]
    let updatedAt: String?
}

struct ProgrammeTheme: Decodable, Identifiable {
    let id: String
    let summary: String?
    let measures: [ProgrammeMeasure]
}

struct ProgrammeMeasure: Decodable {
    let text: String
    let sourceUrl: String
    let sourceLabel: String?
    let date: String?
}

struct ProgrammeThemeInfo {
    let emoji: String
    let label: String
}

// Même liste et même ordre pour tous les candidats (neutralité + comparabilité).
let programmeThemes: [String: ProgrammeThemeInfo] = [
    "economie":             ProgrammeThemeInfo(emoji: "💶", label: "Économie & fiscalité"),
    "travail_retraites":    ProgrammeThemeInfo(emoji: "👷", label: "Travail & retraites"),
    "social_sante":         ProgrammeThemeInfo(emoji: "🏥", label: "Social & santé"),
    "education":            ProgrammeThemeInfo(emoji: "🎓", label: "Éducation & jeunesse"),
    "ecologie_energie":     ProgrammeThemeInfo(emoji: "🌱", label: "Écologie & énergie"),
    "securite_justice":     ProgrammeThemeInfo(emoji: "🛡️", label: "Sécurité & justice"),
    "immigration":          ProgrammeThemeInfo(emoji: "🛂", label: "Immigration"),
    "europe_international": ProgrammeThemeInfo(emoji: "🌍", label: "Europe & international"),
    "institutions":         ProgrammeThemeInfo(emoji: "🏛️", label: "Institutions & démocratie"),
]

// Programmes 100 % locaux : aucun appel serveur. Décodés une seule fois, au premier accès.
enum ProgrammeStore {
    private static let byCandidateId: [String: Programme] = {
        guard let url = Bundle.main.url(forResource: "programmes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(ProgrammesFile.self, from: data)
        else {
            print("[ProgrammeStore] Lecture de programmes.json impossible")
            return [:]
        }
        return Dictionary(file.programmes.map { ($0.candidateId, $0) }, uniquingKeysWith: { first, _ in first })
    }()

    static func programme(for candidateId: String) -> Programme? {
        byCandidateId[candidateId]
    }
}
