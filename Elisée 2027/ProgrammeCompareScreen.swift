import SwiftUI

// Deux programmes côte à côte, thème par thème : chaque thème est une seule carte à deux colonnes,
// pour lire les deux positions d'un coup d'œil. Le second candidat se choisit dans une feuille
// de sélection, ouverte d'emblée à l'arrivée sur l'écran.
struct ProgrammeCompareScreen: View {
    let initialLeftId: String
    /// false quand l'écran est ouvert depuis la vue Programme, où l'avertissement vient d'être vu.
    var showsDisclaimer: Bool = true

    @State private var leftId: String = ""
    @State private var rightId: String?
    @State private var pickerSide: CompareSide?
    @State private var collapsedThemes: Set<String> = []
    @State private var didAppear = false
    // Même clé que la vue Programme : "Ne plus afficher" vaut pour les deux écrans.
    @AppStorage("programmeDisclaimerHidden") private var disclaimerHidden = false
    @State private var showDisclaimer = false
    @State private var didShowDisclaimer = false

    private var left: CandidateInfo? { allCandidates.first { $0.id == leftId } }
    private var right: CandidateInfo? { rightId.flatMap { id in allCandidates.first { $0.id == id } } }
    private var leftProgramme: Programme? { ProgrammeStore.programme(for: leftId) }
    private var rightProgramme: Programme? { rightId.flatMap { ProgrammeStore.programme(for: $0) } }
    private var leftColor: Color { left?.color ?? muted }
    private var rightColor: Color { right?.color ?? muted }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                headers

                // Rappel compact des deux colonnes, collé en haut pendant le défilement.
                Section(header: namesStrip) {
                    let leftHighlights = leftProgramme?.highlights ?? []
                    let rightHighlights = rightProgramme?.highlights ?? []
                    if !leftHighlights.isEmpty || !rightHighlights.isEmpty {
                        sectionTitle("En bref")
                        card {
                            sideBySide(
                                highlightsColumn(leftHighlights, color: leftColor),
                                right == nil
                                    ? AnyView(emptyText("Choisissez un candidat à comparer"))
                                    : AnyView(highlightsColumn(rightHighlights, color: rightColor))
                            )
                        }
                    }

                    sectionTitle("Par thème")
                    ForEach(programmeThemeOrder, id: \.self) { themeId in
                        themeCard(themeId)
                    }

                    footer
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "#0D0D1A").ignoresSafeArea())
        .navigationTitle("Comparer")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .onAppear {
            // onAppear repasse au retour d'un Link externe : on n'initialise qu'une fois.
            guard !didAppear else { return }
            didAppear = true
            leftId = initialLeftId
            pickerSide = .right
        }
        // L'avertissement attend la fermeture de la feuille de sélection, pour ne pas s'empiler dessus.
        .sheet(item: $pickerSide, onDismiss: {
            if showsDisclaimer && !disclaimerHidden && !didShowDisclaimer {
                didShowDisclaimer = true
                showDisclaimer = true
            }
        }) { side in
            CandidatePickerSheet(
                title: side == .left ? "Choisir un candidat" : "Comparer avec…",
                selectedId: side == .left ? leftId : rightId,
                excludedId: side == .left ? rightId : leftId
            ) { id in
                if side == .left { leftId = id } else { rightId = id }
                pickerSide = nil
            }
        }
        .sheet(isPresented: $showDisclaimer) {
            ProgrammeDisclaimerSheet { dontShowAgain in
                if dontShowAgain { disclaimerHidden = true }
                showDisclaimer = false
            }
        }
    }

    // MARK: - Header

    private var headers: some View {
        HStack(alignment: .top, spacing: 4) {
            candidateHeader(left, color: leftColor, programme: leftProgramme) { pickerSide = .left }
            Button {
                guard let r = rightId else { return }
                rightId = leftId
                leftId = r
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(rightId == nil ? muted : .white)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(rightId == nil)
            .accessibilityLabel("Inverser les deux candidats")
            .padding(.top, 22)
            candidateHeader(right, color: rightColor, programme: rightProgramme) { pickerSide = .right }
        }
    }

    private func candidateHeader(
        _ info: CandidateInfo?, color: Color, programme: Programme?, onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                if let info {
                    CompareAvatar(info: info, size: 60)
                    Text(info.name)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    Text(info.party)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 6))
                        .lineLimit(1)
                    if let programme {
                        ProgrammeStatusBadge(status: programme.status)
                        Text(programme.officialUrlIsProgramme == true
                             ? "Programme officiel publié" : "Pas de programme officiel publié")
                            .font(.system(size: 11))
                            .foregroundStyle(muted)
                            .multilineTextAlignment(.center)
                    }
                    Text("Changer ▾")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(muted)
                } else {
                    Text("+")
                        .font(.system(size: 26))
                        .foregroundStyle(muted)
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(muted.opacity(0.6), lineWidth: 1.5))
                    Text("Choisir un candidat")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var namesStrip: some View {
        HStack(spacing: 8) {
            nameTag(left?.name ?? "—", color: leftColor)
            nameTag(right?.name ?? "À choisir", color: rightColor)
        }
        .padding(.vertical, 6)
        .background(Color(hex: "#0D0D1A"))
    }

    private func nameTag(_ name: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Sections

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .kerning(1)
            .foregroundStyle(muted)
            .padding(.top, 8)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#16162A"), in: RoundedRectangle(cornerRadius: 14))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // Deux colonnes de même largeur séparées par un filet ; la hauteur suit la plus longue.
    private func sideBySide<L: View, R: View>(_ left: L, _ right: R) -> some View {
        HStack(alignment: .top, spacing: 21) {
            left.frame(maxWidth: .infinity, alignment: .topLeading)
            right.frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .overlay {
            Rectangle().fill(Color(hex: "#1E1E35")).frame(width: 1)
        }
        .padding(12)
    }

    private func highlightsColumn(_ highlights: [String], color: Color) -> some View {
        Group {
            if highlights.isEmpty {
                emptyText("Pas de mesure phare")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(highlights.enumerated()), id: \.offset) { _, h in
                        HStack(alignment: .top, spacing: 6) {
                            Text("★").font(.system(size: 12)).foregroundStyle(color)
                            Text(h)
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private func themeCard(_ themeId: String) -> some View {
        let meta = programmeThemes[themeId]
        let leftTheme = leftProgramme?.themes.first { $0.id == themeId }
        let rightTheme = rightProgramme?.themes.first { $0.id == themeId }
        // Déplié par défaut : la comparaison se lit d'un seul défilement.
        let isExpanded = !collapsedThemes.contains(themeId)

        return card {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded { collapsedThemes.insert(themeId) } else { collapsedThemes.remove(themeId) }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(meta?.emoji ?? "•").font(.system(size: 20))
                    Text(meta?.label ?? themeId)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer(minLength: 8)
                    countChip(leftTheme?.measures.count ?? 0, color: leftColor)
                    if right != nil {
                        countChip(rightTheme?.measures.count ?? 0, color: rightColor)
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(muted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                sideBySide(
                    themeColumn(leftTheme, color: leftColor, hasProgramme: leftProgramme != nil),
                    right == nil
                        ? AnyView(emptyText("Choisissez un candidat à comparer"))
                        : AnyView(themeColumn(rightTheme, color: rightColor, hasProgramme: rightProgramme != nil))
                )
                .padding(.top, -6)
                .transition(.opacity)
            }
        }
    }

    private func countChip(_ count: Int, color: Color) -> some View {
        let tint = count > 0 ? color : muted
        return Text("\(count)")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func themeColumn(_ theme: ProgrammeTheme?, color: Color, hasProgramme: Bool) -> some View {
        if !hasProgramme {
            emptyText("Programme bientôt disponible")
        } else if let theme, !theme.measures.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                if let summary = theme.summary {
                    Text(summary)
                        .font(.system(size: 12).italic())
                        .foregroundStyle(muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(Array(theme.measures.enumerated()), id: \.offset) { _, measure in
                    measureRow(measure, color: color)
                }
            }
        } else {
            emptyText("Aucune position publiée à ce jour")
        }
    }

    private func measureRow(_ measure: ProgrammeMeasure, color: Color) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Circle().fill(color).frame(width: 5, height: 5).padding(.top, 7)
            VStack(alignment: .leading, spacing: 2) {
                Text(measure.text)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if let url = URL(string: measure.sourceUrl) {
                    let source = [measure.sourceLabel, formatMonth(measure.date)].compactMap { $0 }.joined(separator: " · ")
                    Link(destination: url) {
                        Text("\(source.isEmpty ? "Source" : source) ↗")
                            .font(.system(size: 10))
                            .foregroundStyle(muted)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
            }
        }
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12).italic())
            .foregroundStyle(muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var footer: some View {
        let updates = [
            left.flatMap { info in formatDay(leftProgramme?.updatedAt).map { "\(info.name) le \($0)" } },
            right.flatMap { info in formatDay(rightProgramme?.updatedAt).map { "\(info.name) le \($0)" } },
        ].compactMap { $0 }
        var text = ""
        if !updates.isEmpty { text += "Fiches mises à jour : \(updates.joined(separator: ", ")). " }
        text += "Synthèse réalisée à partir de sources publiques. Tous les candidats n'ont pas publié un programme "
        text += "aussi détaillé : un thème vide signifie qu'aucune position sourcée n'a été trouvée à ce jour. "
        text += "Consultez les sources pour le détail des propositions."
        return Text(text)
            .font(.system(size: 11))
            .foregroundStyle(muted)
            .padding(.top, 12)
            .padding(.horizontal, 4)
    }
}

// MARK: - Picker

private enum CompareSide: String, Identifiable {
    case left, right
    var id: String { rawValue }
}

private struct CandidatePickerSheet: View {
    let title: String
    let selectedId: String?
    let excludedId: String?
    let onPick: (String) -> Void

    // Ordre alphabétique des noms de famille (les ids sont "nom_prenom") : pas de hiérarchie implicite.
    private var choices: [CandidateInfo] {
        allCandidates.filter { $0.id != excludedId }.sorted { $0.id < $1.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(choices) { info in
                        Button { onPick(info.id) } label: {
                            HStack(spacing: 12) {
                                CompareAvatar(info: info, size: 40)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(info.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(info.party)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(info.color)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(info.color.opacity(0.18), in: RoundedRectangle(cornerRadius: 6))
                                }
                                Spacer(minLength: 8)
                                if info.id == selectedId {
                                    Text("✓")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundStyle(info.color)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(info.id == selectedId ? info.color.opacity(0.10) : .clear)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(hex: "#16162A"))
    }
}

private struct CompareAvatar: View {
    let info: CandidateInfo
    let size: CGFloat

    var body: some View {
        Group {
            if let url = info.photoURL {
                RemoteImage(url: url, initials: info.initials, color: info.color)
            } else {
                Text(info.initials)
                    .font(.system(size: size * 16 / 68, weight: .bold))
                    .foregroundStyle(info.color)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .background(info.color.opacity(0.2), in: Circle())
    }
}

private let muted = Color(hex: "#8888AA")

// Ordre fixe des thèmes, identique pour tous les candidats (programmeThemes est un dictionnaire).
private let programmeThemeOrder = [
    "economie", "travail_retraites", "social_sante", "education", "ecologie_energie",
    "securite_justice", "immigration", "europe_international", "institutions",
]
