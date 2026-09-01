import SwiftUI

struct OnboardingScreen: View {
    var onStart: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "#0D0D1A").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elisée 2027")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(.white)
                        Text("Sondage présidentiel participatif")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }

                    // Feature chips 2×2
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        FeatureChip(icon: "lock.shield.fill",  color: "#4CAF50",
                            title: "Pseudonyme",
                            desc: "Identifiant SHA-256 non réversible vers votre identité")
                        FeatureChip(icon: "leaf.fill",         color: "#2E8B57",
                            title: "Écologique",
                            desc: "Backend Rust ultra-léger hébergé en France")
                        FeatureChip(icon: "flag.fill",         color: "#1565C0",
                            title: "France uniquement",
                            desc: "Application destinée aux électeurs français")
                        FeatureChip(icon: "heart.fill",        color: "#E84855",
                            title: "Gratuit & sans pub",
                            desc: "Open source, aucune publicité, aucune donnée vendue")
                    }

                    // Open source
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Open source")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Link("📱 Application IOS", destination: URL(string: "https://github.com/clemPerrousset/Elize2027_app_ios")!)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#7C3AED"))
                        Link("⚙️ Backend Rust", destination: URL(string: "https://github.com/clemPerrousset/Elyze_backend")!)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#7C3AED"))
                    }
                    .padding(14)
                    .background(Color(hex: "#1A1A2E"), in: RoundedRectangle(cornerRadius: 12))

                    // Classement
                    infoBlock(
                        title: "Classement",
                        points: [
                            "Les candidats avec votes sont classés du plus au moins voté.",
                            "Les candidats sans votes sont classés par ordre alphabétique.",
                            "L'application affiche les candidats qui ont déjà annoncé leur candidature ou sont fortement pressentis.",
                        ]
                    )

                    // Avertissements
                    infoBlock(
                        title: "⚠️ À noter",
                        points: [
                            "Les participants ne représentent pas le corps électoral français. Les résultats donnent une tendance, pas une projection.",
                            "L'identifiant pseudonyme est lié à votre appareil. Une réinitialisation usine permet de voter à nouveau.",
                            "Le secret HMAC est embarqué dans l'app et peut être extrait par décompilation — le vote en masse reste possible pour un acteur déterminé.",
                            "Ce sondage n'est pas officiel et n'est affilié à aucun parti politique.",
                            "Le vote peut être annulé ou transféré à tout moment.",
                        ],
                        accentColor: "#F4A300"
                    )

                    // CTA
                    Button(action: onStart) {
                        Text("Commencer")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#C8285C"), Color(hex: "#7C3AED")],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
    }

    private func infoBlock(title: String, points: [String], accentColor: String = "#7C3AED") -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            ForEach(points, id: \.self) { point in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color(hex: accentColor))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(point)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(hex: "#1A1A2E"), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct FeatureChip: View {
    let icon: String
    let color: String
    let title: String
    let desc: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: color))
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
            Text(desc)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#1A1A2E"), in: RoundedRectangle(cornerRadius: 12))
    }
}
