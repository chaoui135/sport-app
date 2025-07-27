# 🛠 UPDATE.md — Manuel de mise à jour de FitVista

## 📅 Objectif

Ce manuel explique comment mettre à jour les différents composants du projet **FitVista**, incluant le frontend Flutter, le backend Node.js ainsi que les dépendances, les fichiers d’environnement et les données.

---

## 🔧 MISE À JOUR DU FRONTEND (Flutter)

1. **Mettre à jour les dépendances Flutter**

```bash
flutter pub upgrade
```

2. **Tester le bon fonctionnement**

```bash
flutter analyze
flutter run
```

3. **Vérifier si des breaking changes sont annoncés**
   Utiliser : [pub.dev](https://pub.dev/)

---

## 🔧 MISE À JOUR DU BACKEND (Node.js)

1. **Mettre à jour les dépendances npm**

```bash
cd backend
npm outdated       # Liste les packages obsolètes
npm update         # Met à jour automatiquement
```

2. **Pour mettre à jour manuellement**

```bash
npm install <package>@latest
```

3. **Tester le backend**

```bash
npm run dev
```

---

## 🌐 MISE À JOUR DE L’ENVIRONNEMENT DE PRODUCTION

1. **Mettre à jour les fichiers .env si besoin**

    * Exemple : changement de clé API, d'URL de base, de token JWT

2. **Rebuilder et redéployer le frontend si l’APK change**

```bash
flutter build apk
```

3. **Redéployer le backend sur Render (ou hébergeur choisi)**

    * Commit + push vers GitHub si déploiement continu configuré

---

## 🚀 BONNES PRATIQUES

* Créer une branche Git par mise à jour majeure
* Réaliser une **sauvegarde** avant toute mise à jour critique
* Ajouter des **releases** et des **tags** Git pour tracer les versions
* Tenir un changelog à jour (ex : `CHANGELOG.md`)

---

