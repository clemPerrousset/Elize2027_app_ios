import SwiftUI

struct ProgrammeScreen: View {
    let info: CandidateInfo

    @State private var expandedThemes: Set<String> = []
    // "Ne plus afficher" coché → masqué définitivement ; sinon réaffiché à chaque ouverture.
    @AppStorage("programmeDisclaimerHidden") private var disclaimerHidden = false
    @State private var showDisclaimer = false
    @State private var dontShowAgain = false

    private var programme: Programme? { ProgrammeStore.programme(for: info.id) }
    private var partyColor: Color { info.color }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header

                if let programme {
                    if let note = programme.programmeNote { infoBox(note) }

                    if let highlights = programme.highlights, !highlights.isEmpty {
                        sectionTitle("En bref")
                        highlightsCard(highlights)
                    }

                    sectionTitle("Par thème")
                    ForEach(programme.themes) { theme in
                        themeSection(theme)
                    }

                    footer(updatedAt: programme.updatedAt)
                } else {
                    infoBox("Programme bientôt disponible pour ce candidat.")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "#0D0D1A").ignoresSafeArea())
        .navigationTitle("Programme")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .onAppear {
            if !disclaimerHidden { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            disclaimerSheet
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(hex: "#16162A"))
        }
    }

    // MARK: - Disclaimer

    private var disclaimerSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📢").font(.system(size: 32))
            Text("Des programmes qui évoluent")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Text("Les programmes peuvent évoluer au cours de la campagne. Certains candidats n'ont pas encore publié de programme officiel : leur fiche repose alors sur leurs déclarations publiques et sera complétée dès sa parution.\n\nMettez régulièrement l'application à jour pour disposer des dernières informations.")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "#8888AA"))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                dontShowAgain.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(dontShowAgain ? Color(hex: "#7B7BFF") : Color(hex: "#8888AA"))
                    Text("Ne plus afficher")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button {
                if dontShowAgain { disclaimerHidden = true }
                showDisclaimer = false
            } label: {
                Text("J'ai compris")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#7B7BFF"), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .padding(.top, 8)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                avatar
                VStack(alignment: .leading, spacing: 6) {
                    Text(info.name)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.white)
                    Text(info.party)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(partyColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(partyColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 6))
                    if let programme { statusBadge(programme.status) }
                }
            }

            if let note = programme?.statusNote {
                Text(note)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#8888AA"))
            }

            if let urlString = programme?.officialUrl, let url = URL(string: urlString) {
                Link(destination: url) {
                    Text("📄 \(programme?.officialUrlLabel ?? "Site officiel") ↗")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(partyColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(partyColor.opacity(0.5), lineWidth: 1))
                }
            }
        }
    }

    private var avatar: some View {
        Group {
            if let url = info.photoURL {
                RemoteImage(url: url, initials: info.initials, color: partyColor)
            } else {
                Text(info.initials)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(partyColor)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
        .background(partyColor.opacity(0.2), in: Circle())
    }

    private func statusBadge(_ status: String) -> some View {
        let (label, color): (String, Color) = switch status {
            case "declared": ("Candidature déclarée", Color(hex: "#4CAF50"))
            case "potential": ("Candidature envisagée", Color(hex: "#FFB300"))
            case "withdrawn": ("Candidature retirée", Color(hex: "#8888AA"))
            default: ("Statut à confirmer", Color(hex: "#8888AA"))
        }
        return HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    // MARK: - Sections

    private func infoBox(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("ℹ️").font(.system(size: 13))
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "#8888AA"))
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(hex: "#1E1E35"), in: RoundedRectangle(cornerRadius: 12))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .kerning(1)
            .foregroundStyle(Color(hex: "#8888AA"))
            .padding(.top, 8)
    }

    private func highlightsCard(_ highlights: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(highlights.enumerated()), id: \.offset) { _, h in
                HStack(alignment: .top, spacing: 8) {
                    Text("★").font(.system(size: 13)).foregroundStyle(partyColor)
                    Text(h).font(.system(size: 14)).foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: "#16162A"), in: RoundedRectangle(cornerRadius: 14))
    }

    private func themeSection(_ theme: ProgrammeTheme) -> some View {
        let meta = programmeThemes[theme.id]
        let isEmpty = theme.measures.isEmpty
        let isExpanded = expandedThemes.contains(theme.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded { expandedThemes.remove(theme.id) } else { expandedThemes.insert(theme.id) }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(meta?.emoji ?? "•").font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meta?.label ?? theme.id)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(isEmpty ? Color(hex: "#8888AA") : .white)
                        if isEmpty {
                            Text("Aucune position publiée à ce jour")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#8888AA"))
                        }
                    }
                    Spacer(minLength: 8)
                    if !isEmpty {
                        Text("\(theme.measures.count)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(partyColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(partyColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "#8888AA"))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isEmpty)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if let summary = theme.summary {
                        Text(summary)
                            .font(.system(size: 13).italic())
                            .foregroundStyle(Color(hex: "#8888AA"))
                    }
                    ForEach(Array(theme.measures.enumerated()), id: \.offset) { _, measure in
                        measureRow(measure)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#16162A"), in: RoundedRectangle(cornerRadius: 14))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func measureRow(_ measure: ProgrammeMeasure) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(partyColor).frame(width: 6, height: 6).padding(.top, 7)
            VStack(alignment: .leading, spacing: 3) {
                Text(measure.text)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if let url = URL(string: measure.sourceUrl) {
                    let source = [measure.sourceLabel, formatMonth(measure.date)].compactMap { $0 }.joined(separator: " · ")
                    Link(destination: url) {
                        Text("Source : \(source.isEmpty ? "lien" : source) ↗")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(hex: "#8888AA"))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }

    private func footer(updatedAt: String?) -> some View {
        var text = ""
        if let day = formatDay(updatedAt) { text += "Mis à jour le \(day). " }
        text += "Synthèse réalisée à partir de sources publiques (programmes, sites officiels, interviews). "
        text += "Consultez les sources pour le détail des propositions."
        return Text(text)
            .font(.system(size: 11))
            .foregroundStyle(Color(hex: "#8888AA"))
            .padding(.top, 12)
    }
}

// MARK: - Helpers

private let monthsFR = ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."]

// "2026-05" → "mai 2026"
private func formatMonth(_ yearMonth: String?) -> String? {
    guard let parts = yearMonth?.split(separator: "-"), parts.count >= 2,
          let month = Int(parts[1]), (1...12).contains(month) else { return nil }
    return "\(monthsFR[month - 1]) \(parts[0])"
}

// "2026-09-23" → "23/09/2026"
private func formatDay(_ isoDate: String?) -> String? {
    guard let parts = isoDate?.split(separator: "-"), parts.count == 3 else { return nil }
    return "\(parts[2])/\(parts[1])/\(parts[0])"
}
