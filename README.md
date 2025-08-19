# 🏋️‍♂️ FitVista — Full-Stack (Flutter + Node/Express + MongoDB)

Application mobile de suivi **sportif & nutritionnel** : objectifs, entraînements, journal d’humeur, recettes, boutique/panier, etc.

- **Frontend** : Flutter
- **Backend** : Node.js / Express
- **Base de données** : MongoDB (Atlas en prod, locale en dev)
- **Déploiement** : Render

---

## 🚀 Démarrage rapide (recommandé pour le jury) — **APP → PROD**

> Cette voie ne nécessite **pas** d’installer MongoDB ni de lancer le backend en local.  
> L’app Flutter pointe directement l’API déployée : `https://fitvista.onrender.com`.

### ✅ Prérequis
- Node.js ≥ 18 + npm
- Flutter SDK ≥ 3.x + Android Studio
- Git

### 📥 Cloner
```bash
git clone https://github.com/chaoui135/sport-app.git
cd sport-app
```

### 🔐 Variables d’env (Flutter)
Crée le fichier `app/.env` (ou `.env` à la racine de l’app si c’est là que tu le lis) à partir de l’exemple :
```bash
cp app/.env.example app/.env     # macOS/Linux
# Windows PowerShell : Copy-Item app/.env.example app/.env
```

Vérifie qu’il contient :
```env
API_URL_PROD=https://fitvista.onrender.com
IS_PROD=true
```

### 📱 Lancer l’app
```bash
flutter pub get
flutter run
```
> L’app utilise l’API **prod**. Si les listes (exos/boutique) sont vides, ajoute 2–3 éléments **en PROD** via l’API (voir « Scénarios de test » plus bas).

---

## 🛠 Installation complète (option) — **APP → BACKEND LOCAL**

> À utiliser si le jury souhaite aussi lancer **le backend** et la **DB** en local.

### ✅ Prérequis supplémentaires
- MongoDB (ou **Docker**)

### 1) Démarrer MongoDB (Docker conseillé)
```bash
docker run --name mongo -p 27017:27017 -d mongo:7
```

### 2) Préparer les `.env`
Backend :
```bash
cd backend && cp .env.example .env && cd ..
```
Le fichier `backend/.env` doit contenir :
```env
DB_URL=mongodb://localhost:27017/sports_exercises
PORT=3000
JWT_SECRET=change-me-dev-secret
```

Flutter :
```bash
cp app/.env.example app/.env
```
Et mettre :
```env
API_URL_DEV=http://10.0.2.2:3000
IS_PROD=false
```
> `10.0.2.2` = alias de `localhost` pour l’émulateur **Android**.  
> iOS Simulator : `http://127.0.0.1:3000`.  
> Appareil physique : mettre l’IP locale de la machine (ex. `http://192.168.1.20:3000`).

### 3) Lancer le backend
```bash
cd backend
npm ci
npm run dev   # lance http://localhost:3000
```

### 4) Vérifier le backend
```bash
curl http://localhost:3000/health   # => 200 + JSON { status:"ok", ... }
```

### 5) Lancer l’app Flutter (dev)
```bash
flutter pub get
flutter run
```

---

## 🔎 Scénarios de test rapides (API)

> Utilise **l’URL locale** si tu es en mode LOCAL (http://localhost:3000),  
> ou **l’URL PROD** si tu es en mode PROD (https://fitvista.onrender.com).

### Utilisateurs
```bash
# Inscription (mot de passe fort requis)
curl -X POST <BASE_URL>/api/users/register   -H "Content-Type: application/json"   -d '{ "userName":"demo","password":"A@a12345!","fullName":"Demo User" }'
```

### Humeurs
```bash
# Créer une humeur (remplacer <USER_ID> par l’_id de l’utilisateur créé)
curl -X POST <BASE_URL>/api/moods   -H "Content-Type: application/json"   -d '{ "mood":"Calme", "user":"<USER_ID>" }'

# Lister
curl <BASE_URL>/api/moods
```

### Exercices (pour remplir l’app)
```bash
curl -X POST <BASE_URL>/api/exercises   -H "Content-Type: application/json"   -d '{ "name":"Pompes", "muscleGroup":"Pectoraux", "difficulty":"Facile", "imageUrl":"https://picsum.photos/300" }'

curl -X POST <BASE_URL>/api/exercises   -H "Content-Type: application/json"   -d '{ "name":"Squat", "muscleGroup":"Jambes", "difficulty":"Moyen", "imageUrl":"https://picsum.photos/301" }'
```

### Produits (boutique)
```bash
curl -X POST <BASE_URL>/api/products   -H "Content-Type: application/json"   -d '{ "name":"Gourde 750ml", "price":12.50, "imageUrl":"https://picsum.photos/303" }'
```

> Remplace `<BASE_URL>` par `http://localhost:3000` (LOCAL) ou `https://fitvista.onrender.com` (PROD).  
> Utilise des **URLs HTTPS** pour les images.

---

## 🧪 Tests backend
```bash
cd backend
npm test          # si "test": "jest" dans package.json
# ou
npx jest
```

---

## 📁 Structure du projet
```
sport-app/
├─ backend/                 # API Node/Express
│  ├─ routes/               # Routes : users, moods, exercises, products...
│  ├─ models/               # Schémas Mongoose
│  ├─ __tests__/            # Jest + MongoMemoryServer
│  ├─ server.js             # Entrée serveur (lit .env)
│  ├─ .env                  # NON versionné
│  └─ .env.example          # Exemple de config env (fourni)
├─ app/ (ou racine Flutter) # App Flutter
│  ├─ lib/                  # Pages, services, models
│  ├─ .env                  # NON versionné
│  └─ .env.example          # Exemple de config env (fourni)
├─ DEPLOYMENT.md
├─ CHANGELOG.md
└─ README.md
```

---

## 🩺 Supervision & Monitoring (prod)
- `GET /health` → état serveur + MongoDB Atlas
- UptimeRobot (uptime/latence/alertes)
- Logs & métriques Render (volumes HTTP)

---

## 🔐 Sécurité
- Ne **jamais** commiter `.env` (utiliser `.env.example`)
- Ne **jamais** publier de secrets (JWT secret, DSN Atlas avec mot de passe)
- Restreindre les IP autorisées sur Atlas (si utilisé)

---

### Notes pour l’évaluateur
- **Mode PROD** (recommandé) : lancer l’appli suffit. Les écrans affichent les données **Atlas** via l’API Render.
- **Mode LOCAL** : lancer Mongo + backend, mettre `IS_PROD=false`, seed rapide via cURL ci-dessus pour voir des données immédiates.
