# 🚀 DEPLOYMENT.md — FitVista

## 📌 Objectif

Ce document décrit les étapes nécessaires pour installer, configurer, tester et déployer le projet **FitVista**, une application mobile développée avec Flutter (Dart) et un backend Node.js (Express). Il couvre les environnements de développement, de test, et de production.

---

## 🧑‍💼 ENVIRONNEMENT DE DÉVELOPPEMENT

| Composant           | Technologie / Outil                |
|---------------------|------------------------------------|
| IDE principal       | Android Studio                     |
| Frontend            | Flutter (Dart)                     |
| Backend             | Node.js (Express)                  |
| Base de données     | MongoDB Atlas ou MongoDB local     |
| Tests backend       | Jest + Supertest + MongoMemoryServer |
| Contrôle de version | Git / GitHub                       |
| Variables d’env.    | `.env` à la racine et dans `backend/` |

---

## 📂 STRUCTURE DU PROJET

```
├── .env                        # URLs API du frontend
├── backend/
│   ├── server.js              # Serveur Express
│   ├── .env                  # Config backend (MongoDB, JWT, PORT)
│   └── __tests__/            # Tests backend avec MongoMemoryServer
├── lib/                       # Frontend Flutter
    └── ...                   # Pages, services, models
```

---

## ⚙️ CONFIGURATION LOCALE

### 1. Cloner le dépôt

```bash
git clone https://github.com/chaoui135/sport-app.git
cd sport-app
```

### 2. Configurer le backend

Dans `backend/.env` :

```env
# Local MongoDB (dev)
DB_URL=mongodb://localhost:27017/sports_exercises
PORT=3000
JWT_SECRET=ultrasecret
```

> Ou, pour MongoDB Atlas (cloud) :

```env
DB_URL=mongodb+srv://fitnessuser:fitnesspass@cluster0.mongodb.net/fitnessdb?retryWrites=true&w=majority
PORT=3000
JWT_SECRET=ultrasecret
```

### 3. Lancer le backend

```bash
cd backend
npm install
node server.js
```

---

### 4. Configurer le frontend (Flutter)

Dans `.env` (racine) :

```env
API_URL_DEV=http://10.0.2.2:3000
API_URL_PROD=https://fitvista.onrender.com
```

Puis :

```bash
flutter pub get
flutter run
```

---

## 🧪 ENVIRONNEMENT DE TEST

- Base de données temporaire en mémoire grâce à `mongodb-memory-server`
- Lancement :

```bash
cd backend
npx jest
```

---

## 🚀 ENVIRONNEMENT DE PRODUCTION

### Backend

- Déployé sur Render
- Utilise MongoDB Atlas
- Variables d’env dans `backend/.env`

### Frontend

- APK Android :

```bash
flutter build apk --release
```

- Web (optionnel) :

```bash
flutter build web
```

---

## ✅ BONNES PRATIQUES

- Ne **jamais** versionner `.env` (`.gitignore` doit l’inclure)
- Changer `JWT_SECRET` pour la production
- Restreindre les IP autorisées sur MongoDB Atlas
- Ne pas exposer les identifiants sur GitHub (scans de secrets)

---


