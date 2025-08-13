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
🐞 **Correctif critique pour mot de passe faible**

- Problème : L'API `POST /api/users/register` acceptait des mots de passe trop simples, exposant les comptes à des attaques par force brute ou credential stuffing.
- Solution : Ajout d'une politique de complexité stricte pour les mots de passe. Désormais, un mot de passe doit contenir au minimum 8 caractères, dont une majuscule, une minuscule, un chiffre et un caractère spécial.
- Impact : L'API retourne une erreur 400 avec un message explicite si le mot de passe est jugé trop faible.
- Ajout d'un utilitaire de validation**
    - La logique de validation a été isolée dans un nouveau module `backend/utils/validator.js` pour être réutilisable et testable de manière unitaire.

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
