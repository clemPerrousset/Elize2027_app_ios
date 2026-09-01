# Fiche App Store Connect — Elisée 2027

> Textes prêts à copier-coller dans App Store Connect. Les limites de caractères d'Apple sont indiquées et respectées.

## Nom de l'app (30 caractères max)

```
Elisée 2027
```
(11/30 caractères)

## Sous-titre (30 caractères max)

```
Sondage présidentiel 2027
```
(25/30 caractères)

## Texte promotionnel (170 caractères max — modifiable sans nouvelle version)

```
Votez pour le candidat de votre choix à la présidentielle 2027. Sondage gratuit, sans pub, open source et hébergé en France.
```
(124/170 caractères)

## Mots-clés (100 caractères max, séparés par des virgules sans espace)

```
election,president,vote,politique,candidat,opinion,scrutin,debat,primaire,actualite
```
(83/100 caractères)

Note : les mots déjà présents dans le nom et le sous-titre ("sondage", "présidentiel", "2027", "elisée") sont déjà indexés par Apple — inutile de les répéter ici.

## Description (4000 caractères max)

```
Elisée 2027 est un sondage présidentiel participatif, gratuit et indépendant, qui vous permet de voter pour le candidat de votre choix à l'élection présidentielle française de 2027.

COMMENT CA MARCHE
Choisissez librement le candidat qui a votre préférence parmi ceux qui ont annoncé leur candidature ou sont fortement pressentis. Votre voix compte immédiatement dans le classement, mis à jour en temps réel.

UN CLASSEMENT EN TEMPS REEL
- Les candidats ayant reçu des votes sont classés du plus au moins voté.
- Les candidats sans vote sont classés par ordre alphabétique.
- Vous pouvez changer d'avis et transférer votre vote à tout moment.

UN VOTE PSEUDONYME, RESPECTUEUX DE VOTRE VIE PRIVEE
Votre participation repose sur un identifiant pseudonyme, généré sur votre appareil et non réversible vers votre identité. Aucune donnée personnelle n'est collectée ni revendue.

UNE APPLICATION LEGERE ET ECOLOGIQUE
Elisée 2027 s'appuie sur un serveur Rust ultra-léger, hébergé en France, pour limiter son empreinte énergétique.

GRATUITE, SANS PUBLICITE, OPEN SOURCE
Aucune publicité, aucune donnée vendue à des tiers. Le code source de l'application et du serveur est public et disponible sur GitHub.

A NOTER
- Les participants à ce sondage ne représentent pas le corps électoral français : les résultats donnent une tendance d'opinion parmi les utilisateurs de l'app, pas une projection électorale.
- Ce sondage est indépendant et non officiel. Il n'est affilié à aucun parti, candidat ou institution.
- L'identifiant de vote est lié à votre appareil ; une réinitialisation usine permet de voter à nouveau.
- Application destinée aux électeurs français.

Elisée 2027 est un projet indépendant et sans but lucratif, créé pour offrir un espace simple et transparent d'expression d'opinion autour de l'élection présidentielle 2027.
```

## Notes de version — What's New (v1.0)

```
Première version d'Elisée 2027 !

- Votez pour le candidat de votre choix à la présidentielle 2027
- Classement en temps réel des candidats
- Vote pseudonyme, sans collecte de données personnelles
- Application gratuite, sans publicité, open source
```

## À compléter manuellement dans App Store Connect

Ces champs nécessitent des informations que je n'ai pas dans le projet — à ne pas inventer :

- **URL de la politique de confidentialité** — obligatoire pour la soumission. Aucune n'existe dans le repo actuellement.
- **URL d'assistance (Support URL)** — par exemple une page GitHub Issues (`https://github.com/clemPerrousset/Elyze2027_app/issues`) ou un email de contact.
- **URL marketing** (optionnelle).
- **Catégorie App Store** — suggestion : *Style de vie* ou *Actualités/Réseautage social* (à choisir selon le positionnement souhaité).
- **Coordonnées de contact** pour la revue Apple.

⚠️ Point d'attention revue Apple : Apple est strict sur les apps liées aux élections/politique (Guideline 1.1 et suivant les périodes électorales, des restrictions supplémentaires peuvent s'appliquer). Les mentions "non officiel", "non affilié" et "tendance d'opinion, pas une projection" dans la description sont importantes à conserver pour la clarté auprès des reviewers.
