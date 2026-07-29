import SwiftUI

// MARK: - Color from hex

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a: UInt64 = h.count == 8 ? int >> 24 : 255
        let r = (int >> 16) & 0xFF
        let g = (int >>  8) & 0xFF
        let b =  int        & 0xFF
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Data models

struct CandidateInfo: Identifiable, Equatable {
    let id: String
    let name: String
    let party: String
    let bloc: String
    let colorHex: String
    let secondaryColorHex: String?
    let photoURL: URL?

    var color: Color { Color(hex: colorHex) }
    var gradient: LinearGradient? {
        guard let sec = secondaryColorHex else { return nil }
        return LinearGradient(
            colors: [Color(hex: colorHex), Color(hex: sec)],
            startPoint: .leading, endPoint: .trailing
        )
    }
    var initials: String {
        name.split(separator: " ")
            .filter { !$0.isEmpty && $0.first!.isLetter }
            .prefix(2)
            .map { String($0.prefix(1)) }
            .joined()
            .uppercased()
    }
}

struct CandidateUiState: Identifiable, Equatable {
    let info: CandidateInfo
    var voteCount: Int = 0
    var progressFraction: Double = 0
    var isVotedFor: Bool = false
    var id: String { info.id }
}

// MARK: - API models

struct VoteCountResponse: Codable {
    let candidates: [CandidateCount]
}
struct CandidateCount: Codable {
    let id: String
    let count: Int
}
struct VoteRequest: Codable {
    let phone_id: String
    let candidate_id: String
    let token: String
}
struct VoteApiResponse: Codable {
    let status: String?
    let error: String?
}
struct DeviceVoteResponse: Codable {
    let candidate_id: String?
}

// MARK: - Candidate list

private let WC = "https://commons.wikimedia.org/wiki/Special:FilePath"

private func candidate(
    _ id: String, _ name: String, _ party: String, _ bloc: String, _ color: String,
    secondary: String? = nil, photo: String? = nil
) -> CandidateInfo {
    CandidateInfo(
        id: id, name: name, party: party, bloc: bloc,
        colorHex: color, secondaryColorHex: secondary,
        photoURL: photo.flatMap { URL(string: $0) }
    )
}

let allCandidates: [CandidateInfo] = [
    candidate("arthaud_nathalie",    "Nathalie Arthaud",      "Lutte ouvrière",      "Extrême gauche",  "#E2001A",
              photo: "\(WC)/Nathalie_Arthaud_(LO)_19-05-2024.jpg"),
    candidate("asselineau_francois", "François Asselineau",   "UPR",                 "Souverainiste",   "#6B8E23",
              photo: "\(WC)/Fran%C3%A7ois_ASSELINEAU.jpg"),
    candidate("melenchon_jeanluc",   "Jean-Luc Mélenchon",    "LFI",                 "Gauche",          "#C8285C",
              secondary: "#7C3AED",
              photo: "\(WC)/Jean-Luc_MELENCHON_2016_2_(cropped).jpg"),
    candidate("tondelier_marine",    "Marine Tondelier",      "Les Écologistes",     "Gauche",          "#2E8B57",
              photo: "\(WC)/Huma2023MarineTondelier.jpg"),
    candidate("guedj_jerome",        "Jérôme Guedj",          "PS",                  "Gauche",          "#E91E63",
              photo: "\(WC)/J%C3%A9r%C3%B4me_Guedj_2010_(cropped).jpg"),
    candidate("bouamrane_karim",     "Karim Bouamrane",       "PS",                  "Gauche",          "#FF6D00"),
    candidate("ruffin_francois",     "François Ruffin",       "Debout !",            "Gauche",          "#B23A48",
              photo: "\(WC)/Fran%C3%A7ois_Ruffin.jpg"),
    candidate("batho_delphine",      "Delphine Batho",        "Génération écologie", "Gauche",          "#4F9D69",
              photo: "\(WC)/Delphine_Batho_p1370391.jpg"),
    candidate("glucksmann_raphael",  "Raphaël Glucksmann",    "Place publique",      "Gauche",          "#F4A300",
              photo: "\(WC)/1720448398743_20240708_GLUCKSMANN_Raphael_FR_006.jpg"),
    candidate("hollande_francois",   "François Hollande",     "PS",                  "Gauche",          "#5C6BC0",
              photo: "\(WC)/Fran%C3%A7ois_Hollande_-_2017_(27869823159).jpg"),
    candidate("faure_olivier",       "Olivier Faure",         "PS",                  "Gauche",          "#E84855",
              photo: "\(WC)/DeputeXIVeLegVeRep-Olivier_Faure.jpg"),
    candidate("lucaslundy_benjamin", "Benjamin Lucas-Lundy",  "Génération·s",        "Gauche",          "#3CB371",
              photo: "\(WC)/20210819_lucas.benjamin_5939.jpg"),
    candidate("massard_lydie",       "Lydie Massard",         "Génération·s",        "Gauche",          "#66CDAA",
              photo: "\(WC)/Lydie_Massard_02-2024.jpg"),
    candidate("retailleau_bruno",    "Bruno Retailleau",      "LR",                  "Droite",          "#0066CC",
              photo: "\(WC)/Bruno_Retailleau.png"),
    candidate("bertrand_xavier",     "Xavier Bertrand",       "Nous France",         "Droite",          "#1B4F8C",
              photo: "\(WC)/Xavier_Bertrand_-_2023_(cropped).jpg"),
    candidate("dupontaignan_nicolas","Nicolas Dupont-Aignan", "Debout la France",    "Droite",          "#003399",
              photo: "\(WC)/Nicolas_Dupont-Aignan,_homme_politique_fran%C3%A7ais.jpg"),
    candidate("lisnard_david",       "David Lisnard",         "Nouvelle Énergie",    "Droite",          "#5DADE2",
              photo: "\(WC)/David_Lisnard_-_2013.jpg"),
    candidate("wauquiez_laurent",    "Laurent Wauquiez",      "LR",                  "Droite",          "#002F6C",
              photo: "\(WC)/Laurent_Wauquiez_2021.jpg"),
    candidate("attal_gabriel",       "Gabriel Attal",         "Renaissance",         "Centre",          "#FFD700",
              photo: "\(WC)/Gabriel_Attal_2023_(cropped).jpg"),
    candidate("philippe_edouard",    "Édouard Philippe",      "Horizons",            "Centre",          "#7FB3D5",
              photo: "\(WC)/%C3%89douard_Philippe_%C3%A0_Ch%C3%A2lons-en-Champagne_en_2023._(cropped).jpg"),
    candidate("darmanin_gerald",     "Gérald Darmanin",       "Renaissance / LR",    "Centre / Droite", "#C8A951",
              photo: "\(WC)/Darmanin_2024_(cropped).jpg"),
    candidate("lepen_marine",        "Marine Le Pen",         "RN",                  "Extrême droite",  "#1565C0",
              photo: "\(WC)/Marine_Le_Pen_2025_(cropped).jpg"),
    candidate("philippot_florian",   "Florian Philippot",     "Les Patriotes",       "Extrême droite",  "#546E7A",
              photo: "https://fr.wikipedia.org/wiki/Special:FilePath/Florian_Philippot_(cropped).JPG"),
    candidate("zemmour_eric",        "Éric Zemmour",          "Reconquête",          "Extrême droite",  "#1A1A40",
              photo: "\(WC)/Portrait_d'%C3%89ric_Zemmour,_avril_2022.jpg"),
]

// MARK: - Mock data

let mockVoteCounts: [String: Int] = [
    "lepen_marine": 8500, "melenchon_jeanluc": 6000, "tondelier_marine": 6000,
    "attal_gabriel": 5200, "philippe_edouard": 4800, "glucksmann_raphael": 3500,
    "ruffin_francois": 2800, "retailleau_bruno": 2400, "wauquiez_laurent": 2100,
    "bertrand_xavier": 1800, "zemmour_eric": 1200, "philippot_florian": 900,
    "darmanin_gerald": 750, "dupontaignan_nicolas": 600, "arthaud_nathalie": 450,
    "asselineau_francois": 320, "guedj_jerome": 280, "bouamrane_karim": 210,
    "hollande_francois": 180, "faure_olivier": 150, "lucaslundy_benjamin": 120,
    "massard_lydie": 90, "batho_delphine": 70, "lisnard_david": 50,
]
