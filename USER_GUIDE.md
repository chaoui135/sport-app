# 📱 USER_GUIDE.md — FitVista

## 🎯 Objectif
Ce manuel explique comment utiliser l'application **FitVista**, que ce soit en local sur un émulateur Android ou après déploiement.

---

## 🏁 Lancement de l’application (mode développeur)

### 📱 Frontend Flutter

1. **Naviguer dans le dossier** :
   ```bash
   cd fitvista
   ```

2. **Installer les dépendances Flutter** :
   ```bash
   flutter pub get
   ```

3. **Lancer l'application sur un émulateur** :
   ```bash
   flutter run
   ```
   > ℹ️ Vérifie qu’un émulateur Android est bien démarré depuis Android Studio.

---

## 🌐 Appels au backend

L’application Flutter communique avec le backend Node.js via des URL définies dans le fichier `.env` à la racine :

```env
API_URL_DEV=http://10.0.2.2:3000
API_URL_PROD=https://fitvista.onrender.com
```

Le fichier `api_config.dart` (dans `lib/services/`) utilise ces variables pour basculer entre local et production.

---

## 🔐 Authentification

- Création de compte utilisateur
- Connexion avec récupération d’un **token JWT**
- Le token est stocké localement et utilisé dans les requêtes sécurisées

---

## 🧩 Fonctionnalités principales

| Fonction                | Description                                                             |
|-------------------------|-------------------------------------------------------------------------|
| Authentification        | Création, connexion, déconnexion avec JWT                               |
| Objectifs personnalisés | Choix d’un objectif + génération de plan                                |
| Suivi nutritionnel      | Accès à des conseils et pages de nutrition                              |
| Suivi de l’humeur       | Ajout d’une humeur quotidienne et historique                            |
| Club de sport           | Recherche de clubs disponibles                                          |
| Boutique                | Ajout d’équipements/produits dans un panier                             |
| Sélection de sport      | Accéder à des exercices techniques adaptés et personnaliser ses séances |
|                         | en combinant différents exercices selon ses objectifs.                  |   
          

---

## ✅ Données de test

- Des jeux de données fictifs sont insérés dans MongoDB (test ou prod)
- On peut aussi interagir via Insomnia :
    - `GET /api/products`
    - `GET /api/exercises`
    - `GET /api/moods`, `POST /api/moods`

---

## 📋 Navigation dans Flutter

- `lib/pages/` : contient les pages comme `home_page.dart`, `auth_page.dart`, `progress_page.dart`
- `lib/models/` : modèles de données (user, goal, cart...)
- `lib/services/` : gestion des appels API
- `lib/widgets/` : composants réutilisables

---


