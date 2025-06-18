# 🚀 DEPLOYMENT.md - Environnements de développement, test et production

## 📌 Objectif
Ce document décrit les environnements de développement, les outils utilisés pour garantir la qualité et les performances, et les différentes étapes de déploiement du projet.

---

## 🧪 ENVIRONNEMENT DE DÉVELOPPEMENT (ANDROID STUDIO)

| Composant | Outil |
|----------|-------|
| IDE principal | Android Studio |
| Frontend | Flutter (Dart) |
| Backend | Node.js avec Express |
| Base de données | MongoDB Atlas |
| Contrôle de version | Git / GitHub |
| Gestion des dépendances (backend) | npm |
| Gestion des dépendances (frontend) | pubspec.yaml |
| Linter (Flutter) | `dart analyze` |
| Logger (Node.js) | `console.log` (peut être amélioré) |

---

## 📦 STRUCTURE DES ENVIRONNEMENTS

### 🔹 Environnement développement

- 📂 Frontend dans `lib/` (Flutter)
- 📂 Backend dans `backend/`
- Variables d’environnement définies dans :
    - `backend/.env`
- Accès local via :
  ```bash
  cd backend
  npm install
  npm run dev
