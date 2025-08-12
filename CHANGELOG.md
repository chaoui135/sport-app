# 🗂️ CHANGELOG - FitVista

---

## [1.0.0] – 2025-06-20
🆕 Première version stable mise en production sur Render

### Fonctionnalités livrées :
- 🔐 Authentification utilisateur (register / login)
- 💪 Génération automatique de programmes sportifs en fonction des objectifs de l'utilisateur
- 🧠 Journal d’humeur avec historique et générateur de citations motivantes
- 🥗 Consultation de recettes nutritionnelles
- 📍 Carte interactive affichant les clubs de sport à proximité
- 📊 Affichage de la progression de l'utilisateur (graphique poids, calories)
- 🛍 Système de boutique + panier
- 🔒 Sécurisation des routes API avec JWT

---

## [1.0.1] – 2025-06-23
🐞 **Correctif critique – Inscription utilisateur**

- Problème : erreur 500 lors de l’inscription avec un `userName` déjà existant
- Cause : absence de vérification d’unicité dans MongoDB
- Solution : ajout d’un bloc `findOne()` + réponse 400 avec message clair
- Bloc encapsulé dans un `try/catch` sécurisé pour éviter tout plantage serveur

---

## [1.0.2] – 2025-07-28
🛡 **Ajout d’un système de supervision**

- Nouveau endpoint `/health` ajouté dans le backend (status serveur + MongoDB)
- Configuration d’un monitoring avec **UptimeRobot** : ping toutes les 5 min
- Historique de consommation (RAM, CPU) accessible via Render
- ⚠ Alerte automatique email en cas de downtime détecté

---


## 🔜 À venir
- 📌 Fonctionnalité de favoris pour les exercices et recettes
- 🧾 Ajout d’un formulaire de feedback dans l’application


---

## [1.1.1] – 2025-10-15
🔧 **Améliorations et optimisations**

- 📱 Optimisation des temps de chargement (lazy loading d’images)
- 🎯 Temps moyen d’accès API réduit de 2.2s à 1.4s
- 📁 Nettoyage de routes obsolètes côté backend
