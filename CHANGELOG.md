Voici une version réécrite et **ordonnée chronologiquement** du changelog de **FitVista**, avec des formulations plus claires et une cohérence stylistique :

---

# 🗂️ CHANGELOG – FitVista

---

## \[1.0.0] – 2025-06-20

🆕 **Lancement officiel – Première version stable déployée sur Render**

### Fonctionnalités initiales :

* 🔐 Authentification (inscription / connexion)
* 💪 Choix d’un objectif personnalisé + génération de plan
* 💪 Sélection de sport + Accès à des exercices techniques adaptés + personnaliser ses séances en combinant différents exercices selon ses objectifs.  
* 🧠 Journal d’humeur avec historique + citations motivantes aléatoires
* 🥗 Consultation de recettes nutritionnelles
* 📍 Carte interactive des clubs de sport à proximité
* 📊 Suivi de la progression utilisateur (graphique poids, calories)
* 🛍 Boutique intégrée avec panier
* 🔒 Sécurisation des routes API via JWT

---

## \[1.0.1] – 2025-06-23

🐞 **Correctif – Renforcement des règles de mot de passe**

* Problème : Les mots de passe trop simples étaient acceptés à l’inscription.
* Solution : Mise en place d’une politique de mot de passe complexe :

  * Min. 8 caractères, incluant majuscule, minuscule, chiffre et caractère spécial.
* ✨ Ajout d’un validateur dédié dans `backend/utils/validator.js`
* ✅ Retour explicite `400` avec message d’erreur si le mot de passe est faible.

---

## \[1.0.2] – 2025-07-28

🛡 **Ajout d’un système de supervision**

* Nouveau endpoint `/health` (statut serveur + MongoDB)
* Intégration UptimeRobot (ping toutes les 5 min)
* Surveillance via Render (RAM / CPU)
* ⚠ Alerte automatique par e-mail en cas de panne détectée

---

## \[1.0.3] – 2025-08-16

🐞 **Correctif – Route `POST /api/moods`**

* Problème : Renvoi d’erreur `500` si corps invalide ou `user` incorrect
* Résolution :

  * Validation stricte : `400` si champs absents, `404` si `userId` inconnu
  * Mapping `userId` (UUID) → `_id` Mongo via `User.findOne()`
  * Réponse `201` avec `{ mood, user: user._id }` sur succès
* 🔬 Tests :

  * Intégration avec MongoMemoryServer (cas 400, 404, 201)
  * Fichier : `backend/__tests__/moodRoute.test.js`
* 👁 Observabilité :

  * Logs Render plus clairs (plus de stack trace 500)
  * `/health` sous monitoring → statut OK
* 📘 Documentation :

  * Changelog mis à jour
  * PR associée : *fix/moods-validate-body*

---

## \[1.1.1] – 2025-10-15

🔧 **Améliorations de performances & nettoyage**

* 📱 Lazy loading des images pour accélérer les chargements
* 🎯 Temps moyen d’accès API réduit (2.2s → 1.4s)
* 📁 Suppression des routes backend obsolètes

---

## 🔜 Prochaines évolutions

* 📌 Ajout des **favoris** pour les exercices et recettes
* 🧾 Intégration d’un **formulaire de feedback** dans l’application

---


