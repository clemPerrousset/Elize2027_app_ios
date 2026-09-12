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
struct VoteHistoryPoint: Codable {
    let date: Int64
    let candidate_id: String
    let votes: Int
}
struct VoteHistoryResponse: Codable {
    let history: [VoteHistoryPoint]
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
    candidate("arthaud_nathalie",    "Nathalie Arthaud",      "Lutte ouvrière",        "Extrême gauche",  "#E2001A",
              photo: "\(WC)/Nathalie_Arthaud_(LO)_19-05-2024.jpg"),
    candidate("kazib_anasse",        "Anasse Kazib",          "Révolution Permanente", "Extrême gauche",  "#C0392B",
              photo: "\(WC)/Anasse_Kazib%2C_d%C3%A9cembre_2021.jpg"),
    candidate("labib_selma",         "Selma Labib",           "NPA-Révolutionnaires",  "Extrême gauche",  "#A6192E"),
    candidate("asselineau_francois", "François Asselineau",   "UPR",                   "Souverainiste",   "#6B8E23",
              photo: "\(WC)/Fran%C3%A7ois_ASSELINEAU.jpg"),
    candidate("lalanne_francis",     "Francis Lalanne",       "France Libre",          "Souverainiste",   "#6C3483",
              photo: "\(WC)/Lalanne_2021_(cropped).jpg"),
    candidate("melenchon_jeanluc",   "Jean-Luc Mélenchon",    "LFI",                   "Gauche",          "#C8285C",
              secondary: "#7C3AED",
              photo: "\(WC)/Jean-Luc_MELENCHON_2016_2_(cropped).jpg"),
    candidate("tondelier_marine",    "Marine Tondelier",      "Les Écologistes",       "Gauche",          "#2E8B57",
              photo: "\(WC)/Huma2023MarineTondelier.jpg"),
    candidate("guedj_jerome",        "Jérôme Guedj",          "PS",                    "Gauche",          "#E91E63",
              photo: "\(WC)/J%C3%A9r%C3%B4me_Guedj_2010_(cropped).jpg"),
    candidate("bouamrane_karim",     "Karim Bouamrane",       "PS",                    "Gauche",          "#FF6D00"),
    candidate("royal_segolene",      "Ségolène Royal",        "PS",                    "Gauche",          "#9C1750",
              photo: "\(WC)/Royal_Toulouse_2012.JPG"),
    candidate("brun_philippe",       "Philippe Brun",         "PS",                    "Gauche",          "#F06292",
              photo: "\(WC)/LOUVIERS_-_4e_circo_Eure_-_Philippe_Brun_nouveau_d%C3%A9put%C3%A9_22_juin_2022_(1)_(cropped).jpg"),
    candidate("ruffin_francois",     "François Ruffin",       "Debout !",              "Gauche",          "#B23A48",
              photo: "\(WC)/Fran%C3%A7ois_Ruffin.jpg"),
    candidate("batho_delphine",      "Delphine Batho",        "Génération écologie",   "Gauche",          "#4F9D69",
              photo: "\(WC)/Delphine_Batho_p1370391.jpg"),
    candidate("glucksmann_raphael",  "Raphaël Glucksmann",    "Place publique",        "Gauche",          "#F4A300",
              photo: "\(WC)/1720448398743_20240708_GLUCKSMANN_Raphael_FR_006.jpg"),
    candidate("faure_olivier",       "Olivier Faure",         "PS",                    "Gauche",          "#E84855",
              photo: "\(WC)/DeputeXIVeLegVeRep-Olivier_Faure.jpg"),
    candidate("massard_lydie",       "Lydie Massard",         "Génération·s",          "Gauche",          "#66CDAA",
              photo: "\(WC)/Lydie_Massard_02-2024.jpg"),
    candidate("roussel_fabien",      "Fabien Roussel",        "PCF",                   "Gauche",          "#B71C1C",
              photo: "\(WC)/Roussel_Fabien_1.jpg"),
    candidate("branco_juan",         "Juan Branco",           "Les Ruches",            "Gauche",          "#F9A825",
              secondary: "#212121", photo: "\(WC)/Juan_Branco_portrait.png"),
    candidate("retailleau_bruno",    "Bruno Retailleau",      "LR",                    "Droite",          "#0066CC",
              photo: "\(WC)/Bruno_Retailleau.png"),
    candidate("bertrand_xavier",     "Xavier Bertrand",       "Nous France",           "Droite",          "#1B4F8C",
              photo: "\(WC)/Xavier_Bertrand_-_2023_(cropped).jpg"),
    candidate("dupontaignan_nicolas","Nicolas Dupont-Aignan", "Debout la France",      "Droite",          "#003399",
              photo: "\(WC)/Nicolas_Dupont-Aignan,_homme_politique_fran%C3%A7ais.jpg"),
    candidate("lisnard_david",       "David Lisnard",         "Nouvelle Énergie",      "Droite",          "#5DADE2",
              photo: "\(WC)/David_Lisnard_-_2013.jpg"),
    candidate("attal_gabriel",       "Gabriel Attal",         "Renaissance",           "Centre",          "#FFD700",
              photo: "\(WC)/Gabriel_Attal_2023_(cropped).jpg"),
    candidate("philippe_edouard",    "Édouard Philippe",      "Horizons",              "Centre",          "#7FB3D5",
              photo: "\(WC)/%C3%89douard_Philippe_%C3%A0_Ch%C3%A2lons-en-Champagne_en_2023._(cropped).jpg"),
    candidate("egger_clara",         "Clara Egger",           "Solution démocratique", "Centre",          "#00ACC1",
              photo: "\(WC)/Clara_Egger.jpg"),
    candidate("lepen_marine",        "Marine Le Pen",         "RN",                    "Extrême droite",  "#1565C0",
              photo: "\(WC)/Marine_Le_Pen_2025_(cropped).jpg"),
    candidate("philippot_florian",   "Florian Philippot",     "Les Patriotes",         "Extrême droite",  "#546E7A",
              photo: "https://fr.wikipedia.org/wiki/Special:FilePath/Florian_Philippot_(cropped).JPG"),
    candidate("mathieu_benoit",      "Benoît Mathieu",        "Indépendant",           "Non classé",      "#16A085"),
]
