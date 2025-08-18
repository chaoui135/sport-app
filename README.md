# 🏋️‍♂️ FitVista — Full-Stack (Flutter + Node/Express + MongoDB)

Application mobile de suivi **sportif & nutritionnel** : objectifs, programmes d’entraînement, journal d’humeur, recettes, boutique/panier, etc.

- **Frontend** : Flutter
- **Backend** : Node.js / Express
- **Base de données** : MongoDB (Atlas ou locale)
- **Déploiement** : Render

---

## 🚀 Démarrage rapide

### ✅ Prérequis

- [Node.js](https://nodejs.org/) ≥ 18 + **npm**
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.x + Android Studio
- **MongoDB** (local ou Atlas)
- **Git**

---

### 📥 Cloner le projet

```bash
git clone https://github.com/chaoui135/sport-app.git
cd sport-app
```

---

## 📁 Structure du projet

```
sport-app/
├─ backend/             # API Node/Express
│  ├─ routes/           # Routes : exercises, users, activities, products...
│  ├─ models/           # Schémas Mongoose
│  ├─ __tests__/        # Tests (Jest + MongoMemoryServer)
│  ├─ server.js         # Point d’entrée
   └─ .env 
│  └─ .env.example      # Exemple de config env
├─ lib/                 # App Flutter
├─ .env                 # Frontend - variables d’environnement
└─ .env.example         # Exemple de config env
├─ DEPLOYMENT.md        # Manuel de déploiement
├─ USER_GUIDE.md        # Guide utilisateur
├─ UPDATE.md            # Suivi des mises à jour
└─ CHANGELOG.md         # Journal de versions (semver)
```

---

## 🔐 Variables d’environnement

### Backend — `backend/.env` (à partir de `.env.example`)

```env
# Local
DB_URL=mongodb://localhost:27017/sports_exercises
PORT=3000
JWT_SECRET=une_cle_ultra_secrete_a_changer

# (Option) MongoDB Atlas
# DB_URL=mongodb+srv://<user>:<pass>@<cluster>/<db>?retryWrites=true&w=majority
```

### Frontend — `.env` (à la racine, lu par `flutter_dotenv`)

```env
API_URL_DEV=http://10.0.2.2:3000
API_URL_PROD=https://fitvista.onrender.com
```



---

## 🛠 Lancer l’environnement

### Backend (Node/Express)

```bash
cd backend
npm install


node server.js   # (prod)
```

#### Endpoints utiles

- Healthcheck : `GET /health`
- Exercices : `GET/POST /api/exercises`
- Utilisateurs : `POST /api/users/register` & `/login`
- Produits : `GET/POST /api/products/*`
- Humeurs : `GET/POST /api/moods`


---

## 🧪 Tests

### Backend (Jest + MongoMemoryServer)

```bash
cd backend
npx jest
```

### (Optionnel) Frontend (Flutter)

```bash
flutter test
```

---

## 📦 Build APK (Flutter)

```bash
flutter build apk --release
```

---

## 🔄 Bascule DEV / PROD (Flutter)

Dans `lib/api_config.dart` :

```dart
const bool isProd = true; // ou false selon le contexte
```

Et dans `.env` :

```env
API_URL_DEV=http://10.0.2.2:3000
API_URL_PROD=https://fitvista.onrender.com
```

---

## 🤖 CI/CD & Déploiement

- **CI** : GitHub Actions (lint, test, build à chaque push/PR)
- **CD** : Render déploie automatiquement depuis `main`

👉 Voir `DEPLOYMENT.md` pour plus de détails

---

## 🩺 Supervision & Monitoring

- `GET /health` → état du serveur + Mongo
- UptimeRobot (monitoring & alertes)
- Logs & métriques via Render

---

## 🔐 Sécurité

- `.env` **jamais commit**
- Fournir `.env.example` avec des clés factices
- Toujours maintenir `.gitignore` à jour

---

## 🧰 FAQ / Dépannage

- **Android emulator** : utiliser `http://10.0.2.2:3000`
- **MongoDB Atlas** : ajouter votre IP à la whitelist
- **CORS** : vérifier les paramètres `cors()` côté backend
- **Port déjà utilisé** : changer `PORT` dans `backend/.env`

---

## 📚 Documentation

- `DEPLOYMENT.md` : Installation & déploiement
- `USER_GUIDE.md` : Parcours utilisateur, fonctionnalités
- `UPDATE.md` : Historique des mises à jour
- `CHANGELOG.md` : Journal de version 
